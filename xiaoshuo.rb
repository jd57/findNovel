#!/usr/bin/env ruby
require 'pp'
require 'net/http'

$Base='https://m.booktxt.net/wapbook/'
class String
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
    #uri = URI('https://m.booktxt.net/wapbook/1562_509772.html')
    uri = URI(url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
  end
    def get_title
      @body.match(/<title>(.*)<\/title>/)[1].encode("UTF-8","gbk")
    end
    def get_txt
      @txt=@body[/<div id="chaptercontent.*\/div>/m].lines[2].encode("UTF-8","gbk").gsub('&nbsp;',' ').gsub('<br /><br />',"\n").gsub('<br />',"\n")
    end
    def txt
      get_txt
      @txt
    end
end

#html=PAGE.new('https://m.booktxt.net/wapbook/1562_509772.html')
index=INDEX.new("1562.html".url)

#content=[]
index.index.each do |index_url|
#  pp index_url.url
  SUBINDEX.new(index_url.url).subindex.each do |a,b|
    #content.push [a,b.gbk]
    puts b.gbk
    puts PAGE.new(a.url).txt
  end
end


