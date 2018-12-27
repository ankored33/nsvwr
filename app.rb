require 'selenium-webdriver'
require 'nokogiri'
require 'csv'
require 'open-uri'


def firstpage(togetterUrl)
    
    driver = Selenium::WebDriver.for :chrome
    p "ready"

    driver.navigate.to togetterUrl # URLを開く
    sleep 10

    tweets = []
    puts driver.title
    driver.find_element(:id, 'more_tweet_btn').click
    sleep 2
    elements = driver.find_elements(:class, 'list_tweet_box')
    sleep 1
    CSV.open("test.csv", "w", :encoding => "SJIS") do |list|
        arr = []
        elements.each do |element|
            begin
                user = element.find_element(:class, 'user_link').text
                body = element.find_element(:class, 'tweet').text
                status = element.find_element(:class, 'status_right').text
                if user.include?("@NJSLYR" || "@dhtls" || "@the_v_njslyr")
                    njslyr = "njslyr"
                else
                    njslyr = "heads"
                end
            rescue
            end
            arr = [user, body, status, njslyr]
            arr.each do |t|
                t.encode!(Encoding::SJIS, :invalid => :replace, :undef => :replace) if t != nil
            end
            list << arr
        end
    end
    driver.quit
    puts "First Page Done!!"
end



    


def andMore(togetterUrl, maxPage)
    for page in 2..maxPage do
        tweets = []
        url = togetterUrl + "?page=#{page}"
        opt = {}
        opt['User-Agent'] = "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
        charset = nil
        html = open(url,opt) do |f|
            charset = f.charset 
            f.read
        end
        # htmlをパース(解析)してオブジェクトを生成
        arr = []
        doc = Nokogiri::HTML.parse( html, nil, charset)
        CSV.open("test.csv", "a", :encoding => "SJIS") do |list|
            doc.css(".list_tweet_box").each do |item|
                user = item.css(".user_link").inner_text.gsub(/\r\n|\r|\n|\s|\t/, "").strip
                body = item.css(".tweet").inner_text
                status = item.css(".status_right").inner_text.strip.gsub("-","/")
                #p status = status.to_s.insert(9, " ").gsub("-","/")
                if user.include?("@NJSLYR" || "@dhtls" || "@the_v_njslyr")
                    njslyr = "njslyr"
                else
                    njslyr = "heads"
                end
                arr = [user, body, status, njslyr]
                arr.each do |t|
                    t.encode!(Encoding::SJIS, :invalid => :replace, :undef => :replace) if t != nil
                end
                list << arr
            end
        end
        sleep(1)
        puts "#{page}/#{maxPage} Done!!!!"
    end
end

togetterUrl = "https://togetter.com/li/1224316"
maxPage = 49

firstpage(togetterUrl)
sleep(2)
andMore(togetterUrl, maxPage)
