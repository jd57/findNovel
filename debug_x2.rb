#!/usr/bin/env ruby
require 'pp'
require 'net/http'

$Base='https://m.booktxt.net/wapbook/'
$Base="https://www.biquge163.com/book/"
$Book="FanRenXiuXianZhiXianJiePian"
class String
  def fix
    self.gsub("\n","")
        .gsub("\r","")
        .gsub("\t","")
	.gsub("<br><br>","\n")
  end
  def gbk
    self.encode("UTF-8","UTF-8",invalid: :replace,undef: :replace)
  end
    
  def url
      $Base+$Book+"/"+self
  end
end

$Txt=Hash.new{""}
      
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
  pp    @chapter_id=@body.match(/var chapter_id = "(\d+)";/)[1]
   pp   @next_page=@body.match(/var next_page = \".*?#$Book\/(.*?)(.html)?";/)[1]
     pp @txt=@body.match(/<div id="content">(.*?)<p>/m)[1].gbk
    pp  $Txt[@chapter_id]+=@txt
  end
  def try_next_page
    PAGE.new(@next_page) if @next_page[@chapter_id]
  end
end

PAGE.new("100884.html")



