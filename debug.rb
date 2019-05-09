#!/usr/bin/env ruby
require 'pp'
require 'net/http'

$Base='https://m.booktxt.net/wapbook/'
class String
  def html
    self.gsub("<br />\r\n&nbsp;&nbsp<br/>本章未完，请点击下一页继续阅读....\r\n","")
        .gsub(';&nbsp;',' ')
        .gsub('&nbsp;',' ')
	.gsub('&nbsp',' ')
	.gsub("<br />\r\n","\n")
	.gsub('<br /><br />',"\n")
	.gsub('<br />',"\n")
	.gsub('<br/>',"\n")
	.gsub("\r\n","\n")

  end
  def gbk
    self.encode("UTF-8","gbk")
  end
    
  def url
      $Base+self
  end
end
      
class INDEX 
  def initialize url
    #uri = URI('https://m.booktxt.net/wapbook/1562.html')
    uri = URI(url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
  end
  def get_index
    txt=@body[/<select name="pageselect.*?\/select>/m]
    @index=txt.scan(/wapbook\/(.*html)/).flatten
  end
  def index
    get_index
    @index
  end
end

class SUBINDEX 
  def initialize url
    #uri = URI('https://m.booktxt.net/wapbook/1562.html')
    uri = URI(url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
  end
  def get_subindex
    txt=@body.scan(/<div class="directoryArea".*?\/div>/m)[1]
    @sub_index=txt.scan(/href="\/wapbook\/(.*?html)">(.*)<\/a>/)
  end
  def subindex
    get_subindex
    @sub_index
  end
end
class PAGE
  def initialize url
    @url=url
    #uri = URI('https://m.booktxt.net/wapbook/1562_509772.html')
    uri = URI(url.url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
  end
    def get_title
      @body.match(/<title>(.*)<\/title>/)[1].encode("UTF-8","gbk")
    end
    def get_txt
      #@body[/<div id="chaptercontent.*?\/div>/m].lines[2...-2].join.encode("UTF-8","gbk").html
      @body.match(/<div id="chaptercontent.*?\/p>(.*?)<p/m)[1].encode("UTF-8","gbk").html
    end
    def get_2txt
      pp try_url=@url.split('.')[0]+"_2.html"
      if @body[/#{try_url}/]
        PAGE.new(try_url).txt
      else
        ""
      end
    end
    def txt
     get_txt+ get_2txt
    end
    def body
      @body
    end
end

#puts PAGE.new("1562_509772.html".url).txt
#puts PAGE.new("4891_2656915.html").txt
puts PAGE.new("4891_5517446.html").txt
#pp File.read(ARGV[0])[/<div id="chaptercontent.*\/div>/m].lines[2]
#.encode("UTF-8","gbk").gsub('&nbsp;',' ').gsub('<br /><br />',"\n").gsub('<br />',"\n")

