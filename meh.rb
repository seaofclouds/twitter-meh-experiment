# meh is a rainy day experiment with atom and twitter
#----------------------------------------------------

#use latest version of sinatra
$:.unshift File.dirname(__FILE__) + '/sinatra/lib'

require 'rubygems'
require 'sinatra'
require 'atom'
require 'net/http'
require 'uri'

helpers do
  def query
    if params[:query]
      params[:query]
    else
      'meh'
    end
  end
  # fancy time
  def time_ago_or_time_stamp(from_time, to_time = Time.now, include_seconds = true, detail = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
      when 0..1           then time = (distance_in_seconds < 60) ? "#{distance_in_seconds} seconds ago" : '1 minute ago'
      when 2..59          then time = "#{distance_in_minutes} minutes ago"
      when 60..90         then time = "1 hour ago"
      when 90..1440       then time = "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
      when 1440..2160     then time = '1 day ago' # 1-1.5 days
      when 2160..2880     then time = "#{(distance_in_minutes.to_f / 1440.0).round} days ago" # 1.5-2 days
      else time = from_time.strftime("%a, %d %b %Y")
    end
    return time_stamp(from_time) if (detail && distance_in_minutes > 2880)
    return time
  end
end

not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

get '/' do  
  feed_url = 'http://search.twitter.com/search.atom?q='+query
  @feed = Atom::Feed.new(Net::HTTP::get(URI::parse(feed_url)))
  haml :index
end

get '/:query' do
  feed_url = 'http://search.twitter.com/search.atom?q='+query
  @feed = Atom::Feed.new(Net::HTTP::get(URI::parse(feed_url)))
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

  %body{:id=>"#{query}"}
    .container
      #content
        = yield
      #footer 
        
@@ index
- @feed.entries.each do |entry|
  .item
    %span.meta
      %span.date= time_ago_or_time_stamp(entry.published) 
      %span.name= entry.authors.first.name.gsub(/\s*(.+)\s*\((.*)\)/im, ' <a href="http://twitter.com/\1">\1</a>')
      %span.separator said
    %span.title= entry.title.gsub(/(\w+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+)/im, '<a href="\1">\1</a>').gsub(/@([a-zA-Z0-9-_]+)([\s,.;]+)/im, '<a href="http://twitter.com/\1">@\1</a>\2').gsub(/(#{query})/im, '<strong class="query">\1</strong>')

@@ main
*
  :margin 0
  :padding 0
  :font-family arial, sans-serif
body#meh
  :background-color #666
  :color #777
  :text-transform uppercase
  :font-size 300%
  :text-align justify
  :line-height .8em
  
  a
    :color #777
    :text-decoration none
  .query
    :color #888
  .item
    :display inline
    &:hover
      :color #999
      .query
        :color #bbb
      a
        :color #aaa
        &:hover
          :color #ccc
        