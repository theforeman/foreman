module Foreman
  class Plugin
    module BuilderAssets
      def webpack_manifest_path
        file_path = File.join(path, 'public', 'webpack', 'manifest.json')
        File.file?(file_path) ? file_path : nil
      end
      
      def package_json_path
        file_path = File.join(path, 'package.json')
        File.file?(file_path) ? file_path : nil
      end
      
      def builder_config_path
        return nil unless package_json_path.present?
        
        package_json_content = JSON.parse(File.read(package_json_path))
        file_path = package_json_content['tfmBuildConfig']
        
        return nil unless file_path.present?
        File.file?(file_path) ? file_path : nil
      end

      def uses_webpack?
        path && (builder_config_path.present? || webpack_manifest_path.present?)
      end
    end
  end
end
