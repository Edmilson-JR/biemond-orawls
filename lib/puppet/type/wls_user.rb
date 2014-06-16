require 'pathname'
require 'easy_type'
require 'utils/wls_access'
require 'utils/settings'
require 'facter'

module Puppet
  #
  newtype(:wls_user) do
    include EasyType
    include Utils::WlsAccess

    desc "This resource allows you to manage user in an WebLogic Secuirty Realm."

    ensurable

    set_command(:wlst)
  
    to_get_raw_resources do
      Puppet.info "index #{name} "
      environment = { "action"=>"index","type"=>"wls_user"}
      wlst template('puppet:///modules/orawls/providers/wls_user/index.py.erb', binding), environment
    end

    on_create  do | command_builder |
      Puppet.info "create #{name}"
      template('puppet:///modules/orawls/providers/wls_user/create.py.erb', binding)
    end

    on_modify  do | command_builder |
      Puppet.info "modify #{name} "
      template('puppet:///modules/orawls/providers/wls_user/modify.py.erb', binding)
    end

    on_destroy  do | command_builder |
      Puppet.info "destroy #{name} "
      template('puppet:///modules/orawls/providers/wls_user/destroy.py.erb', binding)
    end

    parameter :domain
    parameter :name
    parameter :user_name
    parameter :password
    property  :realm
    property  :authenticationprovider
    property  :description

    # map_title_to_attributes(:name, [:domain, parse_domain_title], :user_name) do 
    #   /^((.*\/)?(.*)?)$/
    # end

    def self.title_patterns
      # possible values for /^((.*\/)?(.*)?)$/
      # default/testuser1 with this as regex outcome 
      #    default/testuser1 default/ testuser1
      # testuser1 with this as regex outcome
      #    testuser1  nil  testuser1
      identity  = lambda {|x| x}
      name      = lambda {|x| 
          if x.include? "/"
            x            # it contains a domain
          else
            'default/'+x # add the default domain
          end
        }
      optional  = lambda{ |x| 
          if x.nil?
            'default' # when not found use default
          else
            x[0..-2]  # remove the last char / from domain name
          end
        }
      [
        [
          /^((.*\/)?(.*)?)$/,
          [
            [ :name     , name     ],
            [ :domain   , optional ],
            [ :user_name, identity ]
          ]
        ],
        [
          /^([^=]+)$/,
          [
            [ :name, identity ]
          ]
        ]
      ]
    end

  end
end
