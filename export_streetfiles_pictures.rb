require 'httparty'
require 'hpricot'

base_url = 'http://streetfiles.org/'

if ARGV.size < 2
  puts "Wrong format! Please add your email address and password."
else
  login_name = ARGV[0]
  login_password = ARGV[1]

# trying to authenticate
  puts "Trying to authenticate with data provided.."

  response = HTTParty.get(base_url + 'login/')
  response = HTTParty.post(base_url + 'login/', :body =>  {'_method' => 'POST', 'data[User][permanent]' => 1,
                                                                                'data[User][email]'     => login_name,
                                                                                'data[User][password]'  => login_password},
                                                :headers => {'Cookie' => response.headers['Set-Cookie']})

  @cookie = response.request.options[:headers]['Cookie']

  if response.success? && !response.include?('Your are <u>NOT</u> logged in')
    puts "Successfully logged in.."
    response = HTTParty.get(base_url + 'my/', :headers => {'Cookie' => @cookie}) 

    user_nickname = Hpricot(response).search(".inSideBox//b").inner_html[4..-1].downcase # because of "Hey XXX" invitation
    puts "Export initializing for #{user_nickname}.."
  
# check how much photos user have at all
    response = HTTParty.get(base_url + user_nickname, :headers => {'Cookie' => @cookie})
    inSideBox_elements = Hpricot(response).search(".inSideBox//p//a")
    photos_number = inSideBox_elements.first.inner_html[0..-8].to_i # because of "XXX photos"
    puts "Totally there are #{photos_number} for export.."
    exit if photos_number == 0
# usually there just 20 pictures per page in My Photos category.
    if (1..20).include? photos_number
      total_pages = 1
    else
      total_pages = photos_number % 20 === 0 ? photos_number / 20 : photos_number / 20 + 1
    end
  
    Dir::mkdir("Streetfiles") unless File.exists?("Streetfiles")

    total_pages.times do |page_number|
      response = HTTParty.get(base_url + "my/photos/index/page:#{page_number + 1}", :headers => {'Cookie' => @cookie})
      if response.success?
        images = Hpricot(response).search("/html/body//img")
        images.each do |image|
          image_attribute = image.get_attribute(:alt).gsub(%r([-/\\!@$#%^&*()+=\]\[~`"';\t :|><,.?<]),'_')
          image_attribute = image_attribute + 'x' while File.exists?("Streetfiles/#{image_attribute}.jpg")
          File.open("Streetfiles/#{image_attribute}.jpg", "w") do |pic|
            file_addr = image.get_attribute(:src).sub(/\/S\//,'/')
            if file_addr.include?(base_url)
              puts "Downloading #{image_attribute} picture.."
              pic.write HTTParty.get(file_addr, :headers => {'Cookie' => @cookie})
            end
          end
        end
      end
    end
    puts "Export was successfuly finished! Please check the #{Dir.pwd}/Streetfiles folder."
  else
    puts "Provided account data:\n >> email: #{login_name}\n >> password: #{login_password}\nis not valid or SF server is down."
    puts "Please check the data or try again later."
  end
end
