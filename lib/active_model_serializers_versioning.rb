
module ActiveModelSerializersVersioning
  module VersioningController
    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        if options[:versioning_serializer]
          serializer = versioning_serializer(options[:versioning_serializer])
          if serializer
            options[:serializer] = serializer 
            options.delete(:versioning_serializer)
          end
        end

        super(resource, options)
      end
    end

    def serializers_version_cache
      @serializers_version_cache = ThreadSafe::Cache.new
    end

    def serialize_class_name(version, name)
      "V#{version}::#{name}"
    end

    def serialize_version
      1
    end

    def versioning_serializer(name)
      version = serialize_version
      serializers_version_cache.fetch_or_store(serialize_class_name(version, name)) { search_serializer(version, name) }
    end

    private

      def search_serializer(version, name)
        version.downto(1) do |v|
          n = serialize_class_name(v, name)
          puts "search #{n}"
          return serializers_version_cache[n] if serializers_version_cache[n]
          klass = n.safe_constantize
          return klass if klass
        end
        nil
      end

    extend self
  end
end
