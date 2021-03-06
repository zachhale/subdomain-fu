module ActionController
  module UrlWriter
    def url_for_with_subdomains(options)
      unless SubdomainFu.needs_rewrite?(options[:subdomain], options[:host] || default_url_options[:host])
        options.delete(:subdomain)
      else
        options[:only_path] = false 
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || default_url_options[:host])
      end
      url_for_without_subdomains(options)
    end
    alias_method_chain :url_for, :subdomains
  end
  
  class UrlRewriter #:nodoc:
    private
    
    def rewrite_url_with_subdomains(options)
      unless SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || @request.host_with_port))
        options.delete(:subdomain)
      else
        options[:only_path] = false
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || @request.host_with_port)
      end
      rewrite_url_without_subdomains(options)
    end
    alias_method_chain :rewrite_url, :subdomains
  end
  
  # hack for http://www.portallabs.com/blog/?p=8
  module Routing
    module Optimisation
      class PositionalArgumentsWithAdditionalParams
        def guard_condition_with_subdomains
          # don't allow optimisation if a subdomain is present - fixes a problem
          # with the subdomain appearing in the query instead of being rewritten
          # see http://mbleigh.lighthouseapp.com/projects/13148/tickets/8-improper-generated-urls-with-named-routes-for-a-singular-resource
          guard_condition_without_subdomains + " && !args.last.has_key?(:subdomain)"
        end

        alias_method_chain :guard_condition, :subdomains
      end
    end
  end
end