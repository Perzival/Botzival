require 'mechanize'
require 'inifile'
#ini file setup
#[Settings]
#API_Key = Your API Key
#directory = Where the images will be downloaded
ini = IniFile.load("#{File.expand_path(File.dirname(__FILE__))}/settings.ini") # Create a new inifile object.
s = ini['Settings']    # Get the settings
a = Mechanize.new { |agent|
  agent.user_agent = "Botzival Watched List Downloader"
  agent.follow_meta_refresh = true
  agent.pluggable_parser.default = Mechanize::Page
  agent.pluggable_parser['image'] = Mechanize::DirectorySaver.save_to s['directory']
}
derpi = a.get("http://derpiboo.ru/images/watched.rss?key=#{s['API_Key']}&per_page=100")
page = 1
currentitems = Dir.entries(s['directory'])
until derpi.links.nil?
  derpi.links.each do |img|
	unless (currentitems.grep Regexp.new("^#{img.href.sub(/^http.*:\/\/derpiboo\.ru\//, '')}")).empty? then
	  puts "Skipping #{img.href} as already downloaded"
	  next
	end
    a.get(img.href)
    begin
      a.click('Download')
    rescue
	  puts "\033[1m\033[31m----------------------------------------------------------------"
      puts "Error when downloading, 404 when downloading image probably."
      puts "Contact the mods on IRC and say that image #{img.href.sub(/^http.*:\/\/derpiboo\.ru\//, '')} is broken."
      puts "They'll handle it."
      puts "-----------------------------------------------------------------\033[0m\033[22m"
      raise
    end
    puts "#{img.href} downloaded."
  end
  page = page + 1
  puts "On page #{page}."
  derpi = a.get("http://derpiboo.ru/images/watched.rss?key=#{s['API_Key']}&per_page=100&page=#{page}")
end
