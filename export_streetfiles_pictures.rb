require 'httparty'
require 'hpricot'

BASE_URL = 'http://streetfiles.org/'

def basic_authentication(email, password)
  puts "Trying to authenticate with data provided.."
  
  response = HTTParty.get(BASE_URL + 'login/')
  response = HTTParty.post(BASE_URL + 'login/', :body =>  {'_method' => 'POST', 'data[User][permanent]' => 1,
                                                                                'data[User][email]'     => email,
                                                                                'data[User][password]'  => password},
                                                :headers => {'Cookie' => response.headers['Set-Cookie']})
  
  @cookie = response.request.options[:headers]['Cookie']
  if response.success? && !response.include?('Your are <u>NOT</u> logged in')
    puts "Successfully logged in.."
  else
    puts "Provided account data:\n >> email: #{email}\n >> password: #{password}\nis not valid or SF server is down."
    puts "Please check the data or try again later."
  end
end

def create_streetfiles_folder
  Dir::mkdir("Streetfiles") unless File.exists?("Streetfiles")
end

def download_images_through_pages(total_pages, url_prefix, folder_name)
  Dir::mkdir("Streetfiles/#{folder_name}") unless File.exists?("Streetfiles/#{folder_name}")
  total_pages.times do |page_number|
    response = HTTParty.get(BASE_URL + "my/#{url_prefix}/page:#{page_number + 1}", :headers => {'Cookie' => @cookie})
    if response.success?
      images = Hpricot(response).search("/html/body//img")
      images.each do |image|
        image_attribute = image.get_attribute(:alt).gsub(%r([-/\\!@$#%^&*()+=\]\[~`"';\t :|><,.?<]),'_')
        image_attribute = image_attribute + 'x' while File.exists?("Streetfiles/#{folder_name}/#{image_attribute}.jpg")
        File.open("Streetfiles/#{folder_name}/#{image_attribute}.jpg", "w") do |pic|
          file_addr = image.get_attribute(:src).sub(/\/S\//,'/')
          if file_addr.include?(BASE_URL)
            puts "Downloading #{image_attribute} picture.."
            pic.write HTTParty.get(file_addr, :headers => {'Cookie' => @cookie})
          end
        end
      end
    end
  end
  puts "Export was successfuly finished! Please check the #{Dir.pwd}/Streetfiles/#{folder_name} folder."
end

def get_user_name
  response = HTTParty.get(BASE_URL + 'my/', :headers => {'Cookie' => @cookie}) 

  @user_nickname = Hpricot(response).search(".inSideBox//b").inner_html[4..-1].downcase # because of "Hey XXX" invitation
  puts "Export initializing for #{@user_nickname}.."
end

def get_total_pages_number(index_url)
  response = HTTParty.get(BASE_URL + "my/#{index_url}/", :headers => {'Cookie' => @cookie})
  pagination_elements = Hpricot(response).search(".pageNums//a")[-2]
  pages_number = !pagination_elements.nil? ? pagination_elements.inner_html.to_i : 1
  pages_number
end

if ARGV.size < 3
  puts "Wrong format! Please add download option, your email address and password."
else
  download_option = ARGV[0]
  login_name = ARGV[1]
  login_password = ARGV[2]

  if %w(-m -l -b).include?(download_option)
    basic_authentication(login_name, login_password)
    create_streetfiles_folder
    get_user_name

    case download_option
    when "-m"
      prefix = "photos/index"
# check how much photos user have at all
      response = HTTParty.get(BASE_URL + @user_nickname, :headers => {'Cookie' => @cookie})
      inSideBox_elements = Hpricot(response).search(".inSideBox//p//a")
      photos_number = inSideBox_elements.first.inner_html[0..-8].to_i # because of "XXX photos"
      puts "Totally there are #{photos_number} for export.."
      exit if photos_number == 0

      total_pages = get_total_pages_number(prefix)
      download_images_through_pages(total_pages, prefix, "Mine")
    when "-l"
      prefix = "activities/loves"
      total_pages = get_total_pages_number(prefix)
      download_images_through_pages(total_pages, prefix, "Loved")
    when "-b"
      prefix = "activities/bookmarks"
      total_pages = get_total_pages_number(prefix)
      download_images_through_pages(total_pages, prefix, "Bookmarks")
    end
  else
    puts "Wrong download option was specified. Please use:\n -m : to download just your photos\n -l : to download your loved photos\n -b : to download your bookmarks."
  end
end
