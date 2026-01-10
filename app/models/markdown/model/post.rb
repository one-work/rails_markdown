module Markdown
  module Model::Post
    extend ActiveSupport::Concern
    include Com::Ext::Markdown

    included do
      attribute :layout, :string
      attribute :path, :string
      attribute :slug, :string
      attribute :catalog_path, :string
      attribute :oid, :string
      attribute :position, :integer
      attribute :published, :boolean, default: true
      attribute :shared, :boolean, default: false
      attribute :ppt, :boolean, default: false
      attribute :nav, :boolean, default: false, comment: '是否导航菜单'
      attribute :last_commit_at, :datetime

      enum :target, {
        target_self: 'target_self',
        target_blank: 'target_blank',
        target_parent: 'target_parent',
        target_top: 'target_top'
      }, default: 'target_self'

      belongs_to :git
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :catalog, foreign_key: [:git_id, :catalog_path], primary_key: [:git_id, :path]

      scope :published, -> { where(published: true) }
      scope :nav, -> { where(nav: true) }
      scope :shared, -> { where(shared: true) }
      scope :ordered, -> { order(position: :asc) }

      positioned on: [:git_id, :catalog_path]

      normalizes :catalog_path, with: -> path { path.to_s }

      before_validation :sync_organ, if: -> { git_id_changed? }
      before_validation :sync_from_path, if: -> { path_changed? }
      before_save :sync_to_html, if: -> { markdown_changed? }
    end

    def clear_items(items)
      if items.is_a?(Array) && items.all? { |_i| _i.type == :blank }
        items.delete_if { |_i| _i.type == :blank }
      else
        items
      end
    end

    def blocks(items = new_contents, level = 2)
      proc = ->(i){ i.type == :header && i.options[:level] == level }
      if items.find(&proc)
        items.slice_before(&proc).map do |m|
          idx = m.index { |i| i.type == :header }
          if idx
            arr = {}
            arr.merge! header: m.delete_at(idx)
            arr.merge!(
              items: blocks(m, level + 1),
              link: m.extract! { |j| j.children.present? && j.children.all?(&->(k){ k.type == :a }) }
            ).compact_blank
          else
            clear_items(m)
          end
        end.compact_blank
      else
        clear_items(items)
      end
    end

    def raw_blocks
      blocks.delete_if { |i| i[:header].options[:level] == 1 }
    end

    def block_texts(_blocks = blocks, text = '')
      _blocks.map do |block|
        if block.is_a?(Hash)
          block.each do |k, v|
            if v.is_a?(Array)
              block[k] = block_texts(v, text)
            else
              block[k] = converter.convert(v, 0)
            end
          end
        elsif block.is_a?(Array)
          block_texts(block, text)
        else
          converter.convert(block, 0)
        end
      end
    end

    def raw_block_texts
      block_texts(raw_blocks)
    end

    def last_commit_at
      super || created_at
    end

    def real_path
      git.real_path.join(path)
    end

    def ppt_content
      Marp.parse(markdown)
    end

    def fresh!
      r = git.sync_files path
      r.each(&:save!)
    end

    def sync_organ
      self.organ_id = git.organ_id
    end

    def sync_from_path
      r = path.split('/')

      self.catalog_path = r[0..-2].join('/')
      self.slug = path.delete_suffix('.md')
      self.catalog || self.create_catalog
      self
    end

    def based_posts_path
      if git.base_name.present?
        "/#{git.base_name}/posts/#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      else
        "/posts/#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      end
    end

    def based_assets_path
      if git.base_name.present?
        "/markdown/#{git.base_name}/assets/#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      else
        "/markdown/assets/#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      end
    end

    def convert_link(link)
      if link.attr['href'].start_with?('http', '//')
        link.attr['target'] = '_blank'
      elsif link.attr['href'].start_with?('/')
        link.attr['target'] = '_blank' if target_blank?
      elsif link.attr['href'].start_with?('#')
      else
        link.attr['href'].prepend based_posts_path
        link.attr['href'].delete_suffix!('.md')
      end
    end

    def sync_to_html
      self.ppt = is_ppt?
      self
    end

    def paths
      catalog.ancestors.reject { |i| i.name.blank? }
    end

    def is_ppt?
      markdown.start_with?("---\n")
    end

    def home?
      catalog.home_path == path
    end

  end
end
