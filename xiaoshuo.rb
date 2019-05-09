#!/usr/bin/env ruby
require 'pp'
require 'net/http'

$Base='https://m.booktxt.net/wapbook/'
class String
  def html
    self.gsub("本章未完，请点击下一页继续阅读....","")
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
    self.encode("UTF-8","gbk",invalid: :replace, undef: :replace)
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
    @index=txt.scan(/wapbook\/(.*?html)/).flatten
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
      @body.match(/<title>(.*)<\/title>/)[1].gbk
    end
    def get_txt
      #@body[/<div id="chaptercontent.*?\/div>/m].lines[2...-2].join.encode("UTF-8","gbk").html
      begin
      @body.match(/<div id="chaptercontent.*?\/p>(.*?)<p/m)[1].gbk.html
      rescue
      pp @body
      exit
      end
    end
    def get_2txt
      try_url=@url.split('.')[0]+"_2.html"
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
#"1562"
bookid=ARGV[0].to_s+".html"
index=INDEX.new(bookid.url)

id=[]
content={}
txt={}

thread=[]
thread1=[]

index.index.each_with_index do |index_url,n|
  thread[n]=Thread.new{
    SUBINDEX.new(index_url.url).subindex.each do |a,b|
      id.push [a]
      content[a]=b.gbk
    end
  }
  sleep 0.1
end
thread.each{|t| t.join}

id.uniq!.flatten!


#pp content.sort!
#sleep 10

id.each_slice(id.size/20).each_with_index do |a,n|
  thread1[n]=Thread.new{
    a.each do |u|
      txt[u]=PAGE.new(u).txt
#      begin
#      rescue
#        puts txt
#        puts "XXXX"
#	exit
#      end
    end
  }
end
thread1.each{|t| t.join}

id.sort.each do |e|
  puts content[e]
  puts txt[e]
end
