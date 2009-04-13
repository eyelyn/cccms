require 'csv'


class AuthorsImporter
  
  def initialize path
    @parsed_file = CSV::Reader.parse(File.open(path, "r")) if File.exists? path
  end
  
  def import_authors
    parse_csv || find_or_create_user
  end
  
  def parse_csv
    if @parsed_file
      @parsed_file.each do |row|
        password = generate_password
                
        options = {
          :login                  => row[0],
          :full_name              => row[1],
          :email                  => row[2],
          :password               => password,
          :password_confirmation  => password
        }
        
        find_or_create_user options
      end
      
      return true
    end
  end
  
  def find_or_create_user options = {}
    password = generate_password
    
    # default_options = {
    #   :login => "webmaster",
    #   :full_name => "Webmaster",
    #   :email => "webmaster@ccc.de",
    #   :password => password,
    #   :password_confirmation => password
    # }
    # default_options = {}
    # 
    # options = default_options.merge(options)
    puts options[:login]
    
    unless User.find_by_email(options[:email])
      
      User.create! options
    end
  end
  
  def generate_password
    Digest::SHA1.hexdigest("#{Time.now+rand(10000).days}")
  end
end