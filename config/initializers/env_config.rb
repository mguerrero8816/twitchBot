ENVIRONMENTS_CONFIG = YAML.load(File.read("#{Rails.root}/config/environments.yml"))
ENV['foo'] ||= ENVIRONMENTS_CONFIG['foo']
ENV['secret_key_base'] ||= ENVIRONMENTS_CONFIG['secret_key_base']