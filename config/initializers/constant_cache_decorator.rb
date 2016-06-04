ConstantCache::CacheMethods::ClassMethods.module_eval do

  def caches_constants(additional_options = {})
    cattr_accessor :cache_options

    self.cache_options = {:key => :name, :limit => ConstantCache::CHARACTER_LIMIT}.merge(additional_options)

    raise ConstantCache::InvalidLimitError, "Limit of #{self.cache_options[:limit]} is invalid" if self.cache_options[:limit] < 1
    self.all.each {|model| model.set_instance_as_constant }
  end

end