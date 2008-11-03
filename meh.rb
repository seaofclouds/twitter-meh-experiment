# be advised, this script currently does not work
#------------------------------------------------

#use latest version of sinatra
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/sinatra/lib')

require 'rubygems'
require 'sinatra'
require 'atom' #sudo gem install ratom
#require 'net/http'
require 'uri'
 
not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

configure do
end

get '/' do
  feed_url = 'http://search.twitter.com/search.atom?q=meh'
  #feed = Atom::Feed.new(Net::HTTP::get(URI::parse(feed_url))) #struggling with atom
  feed = Atom::Feed.load_feed(URI.parse(feed_url)) #struggling with ratom/lib-xml
  haml :index
end

# stylesheets

get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :main
end

use_in_file_templates!

__END__

@@ layout
!!! XML
!!! Strict
%html{ :xmlns => "http://www.w3.org/1999/xhtml", :lang => "en", 'xml:lang' => "en" }
  %head
    %title meh
    %meta{'http-equiv'=>"content-type", :content=>"text/html; charset=UTF-8"}/
    %link{:href=>"/main.css", :media=>"all", :rel=>"stylesheet", :type=>"text/css"}/
    %script{:type=>"text/javascript"}
      :plain

  %body
    .container
      #content
        = yield
      #footer 
        
@@ index
%p
  -# feed.entries.each do |entry|
  - feed.each_entry.each do |entry|
    %span= entry.title
    by
    %span= entry.authors.first.name
    on
    -#%a{:href="#{entry.link}"}= entry.published.strftime('%m/%d/%Y')
  
@@ main
*
  :margin 0
  :padding 0
  :font-family arial, sans-serif
body
  :background-color #777
  :color #999
  a
    :color #999
