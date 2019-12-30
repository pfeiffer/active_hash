module ActiveFile

  class Base < ActiveHash::Base
    extend ActiveFile::MultipleFiles

    class_attribute :filename, :root_path, instance_reader: false, instance_writer: false

    @@mutex = Mutex.new

    class << self

      def delete_all
        @@mutex.synchronize do
          self.data = []
          super
        end
      end

      def reload(force = false)
        @@mutex.synchronize do
          return if !self.dirty && !force && data_loaded?
          self.data = load_file
          mark_clean
        end
      end

      def set_filename(name)
        self.filename = name
      end

      def set_root_path(path)
        self.root_path = path
      end

      def load_file
        raise "Override Me"
      end

      def full_path
        actual_filename  = filename   || name.tableize
        File.join(actual_root_path, "#{actual_filename}.#{extension}")
      end

      def data_loaded?
        !data.nil?
      end

      def extension
        raise "Override Me"
      end
      protected :extension

      def actual_root_path
        root_path  || Dir.pwd
      end
      protected :actual_root_path

      [:find, :find_by_id, :all, :where, :method_missing].each do |method|
        define_method(method) do |*args|
          reload unless data_loaded?
          return super(*args)
        end
      end

    end
  end

end
