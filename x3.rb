#!/usr/bin/env ruby
#encoding: UTF-8
require 'pp'
require 'net/http'

$Thread=10
$Base='https://m.booktxt.net/wapbook/'
$Base="https://www.biqugeii.com/"
$Book="3_3973"
class String
  def fix
    self.gsub("\n","")
        .gsub("\r","")
        .gsub("\t","")
        .gsub("&nbsp;","")
	.gsub("<br><br>","\n\n")
	.gsub("<br /><br />","\n\n")
  end
  def gbk
    self.encode("UTF-8","gbk",invalid: :replace,undef: :replace)
  end
    
  def url
      $Base+$Book+"/"+self
  end
end

$Txt=Hash.new{""}
$Content=Hash.new{""}
      
class INDEX 
  def initialize url
    #uri = URI('https://m.booktxt.net/wapbook/1562.html')
    uri = URI(url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
  end
  def get_index
    @index=@body.scan(/#{$Book}\/(\d+.html)/).flatten.uniq.sort
  end
  def index
    get_index
    @index
  end
end

class PAGE
  def initialize url
    uri = URI(url.url)
    @res = Net::HTTP.get_response(uri)
    @body=@res.body
    self.get_para
    self.try_next_page
  end
  def get_para
    begin
      @chapter_id=@body.match(/var chapter_id = "(\d+)";/)[1]
      @next_page=@body.match(/var next_page = \".*?#$Book\/(.*?)(.html)?";/)[1]
      @chapter_name=@body.match(/<h1>(.*)<\/h1>/)[1]
      @txt=@body.match(/<div id="content">(.*?)<\/div>/m)[1]
      $Content[@chapter_id]=@chapter_name
      $Txt[@chapter_id]+=@txt
    rescue 
      pp @body
      exit
    end
  end
  def try_next_page
    PAGE.new(@next_page) if @next_page[@chapter_id]
  end
end

thread=[]
 $index =INDEX.new("".url).index

$index.each_slice($index.size/$Thread).each_with_index do |e,n|
  thread[n]=Thread.new {
    e.each do |r|
      PAGE.new(r)
    end
  }
end


thread.each{|t| t.join}

tmp=""
#f=File.new("XZZ","w:UTF-8")
f=File.new("ZanZhongLu","w")
f.puts "# ZanZhongLu"
$index.each do |e|
  idx=e.split(".")[0]
  g=$Content[idx].gbk
  a,b,c=g.split(" ")[0,3]
  if tmp==a
     f.puts "## "+b+" "+c
  else 
     f.puts "# "+a
     f.puts "## "+b+" "+c
     tmp=a
  end
  f.puts "  "+$Txt[idx].gbk.fix
end



