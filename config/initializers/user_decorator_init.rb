# Ensure that Spree.user_class includes the UserMethods concern
# Previously these methods were injected automatically onto the class, which we
# are still doing for compatability, but with a warning.

Spree::Core::Engine.config.to_prepare do
  Spree::User.class_eval do
    self.whitelisted_ransackable_attributes.push('promoter_id')
  end
end
