require 'prime'
require 'nokogiri'
require 'open-uri'
require 'digest/md5'



class DomainCrawler < ApplicationRecord
  has_many :crawler_pages, :dependent => :destroy
  belongs_to :crawler_page
  @previous_time =0
  @@primes = Prime.instance

  def TimeLogger(str)

    if @previous_time == 0

      @previous_time = Time.now

    else

      time_now = Time.now

      interval = time_now - @previous_time

      @previous_time = time_now

      logger.info "#{@a} Time: #{interval}, #{str} "

      @a=@a+1
    end

  end

  BEGIN_TOKEN = 0
  END_TOKEN = 1
  END_TAG = 2
  PRIME = 3
  TAG_STRUCTS = [[],["<td[^>]*>", "<\/td[^>]*>", "</td>", 2],["<tr[^>]*>", "<\/tr[^>]*>", "</tr>", 3],["<table[^>]*>", "<\/table[^>]*>", "</table>", 5], ["<p[^>]*>", "<\/p[^>]*>", "</p>", 7]]

  def fix_html(html_content)
    tag_indices = []
    (TAG_STRUCTS.size-1).times.each do |struc_ind|
      html_content.to_enum(:scan, /#{TAG_STRUCTS[struc_ind+1][BEGIN_TOKEN]}/im).map { Regexp.last_match }.map { |match| tag_indices << [match.offset(0)[0],match.offset(0)[1], struc_ind+1] }
      html_content.to_enum(:scan, /#{TAG_STRUCTS[struc_ind+1][END_TOKEN]}/im).map { Regexp.last_match }.map { |match| tag_indices <<[match.offset(0)[0],match.offset(0)[1],  -struc_ind-1] }
    end
    tag_indices.sort!
    tag_multiple = 1
    tag_changes = []
    tag_indices.size.times.each do |tag_ind|
      struc_ind = tag_indices[tag_ind][2]
      insert_pos = tag_indices[tag_ind][0]
      if struc_ind > 0
        prime = TAG_STRUCTS[struc_ind][PRIME]
        if tag_multiple%prime==0
# this means an end tag is missing. We have to supply the end tags for all struc ids <= struc_id

          (struc_ind-1).times do |id|
            l_prime = TAG_STRUCTS[id+1][PRIME]
            if tag_multiple%l_prime == 0
              tag_changes<<[insert_pos, TAG_STRUCTS[id+1][END_TAG]]
              tag_multiple = tag_multiple/l_prime
            end
          end
          tag_changes<<[insert_pos, TAG_STRUCTS[struc_ind][END_TAG]]
        else
          tag_multiple =tag_multiple*prime
        end
      else
        prime = TAG_STRUCTS[-struc_ind][PRIME]
        if tag_multiple%prime==0
          tag_multiple =tag_multiple/prime
          (-struc_ind-1).times do |id|
            l_prime = TAG_STRUCTS[id+1][PRIME]
            if tag_multiple%l_prime == 0
              tag_changes<<[insert_pos, TAG_STRUCTS[id+1][END_TAG]]
              tag_multiple = tag_multiple/l_prime
            end
          end
        else
          tag_changes << [tag_indices[tag_ind][0],tag_indices[tag_ind][1] ]
        end
      end
    end
 #   puts tag_changes
    tag_changes.reverse_each do |change|
      if change[1].is_a? Integer
       # puts "Removing #{change.inspect}"
        html_content[change[0],change[1]-change[0]]=""
      else
       # puts "inserting #{change.inspect}"
        html_content.insert(change[0],change[1])
      end
    end

  end

  def GetNextPrime(n)
    if n%2 == 0
      possible_prime = n+1
    else
      possible_prime = n+2
    end
    if @@primes == nil
      @@primes = Prime.instance
    end

    while @@primes.prime?(possible_prime) == false
      possible_prime = possible_prime + 2
      #       logger.info "v8"
    end
    return possible_prime

  end

  def sql_save(sql_str)

    @connection.execute(sql_str)
    save_sql = SaveMySql.new
    save_sql.save_str = sql_str[0..1000]
    save_sql.save
  end

  def AddSentencesAndWords()
    logger.info "AddSentencesAndWords begin"
    # logger.info "rwv1001 g"
    if Sentence.exists?
      max_id = Sentence.maximum('id')
      #   logger.info "rwv1001 h"
    else
      max_id = 0
      logger.info "No sentences exist"
    end
    if @sentence_inserts.length >0
      #   logger.info "rwv1001 i"
      sql = %Q"INSERT INTO sentences (content, accented, deaccented_content, paragraph_id) VALUES #{@sentence_inserts.to_a.join(', ')}"
      sql_save(sql)
      # logger.info "rwv1001 j"

    else
      logger.info "@sentence_inserts is empty"
    end
    @sentence_objects = Sentence.where("id > #{max_id}").order("id asc")

    if @word_entries.length > 0

      #sql = "INSERT IGNORE INTO words (word_name, id_value, word_prime) VALUES #{@word_entries.to_a.join(', ')}"
      sql = "INSERT INTO words (word_name, id_value, word_prime) VALUES #{@word_entries.to_a.join(', ')}"
      #logger.info "sql = #{sql}"
      sql_save(sql)
      #  logger.info "rwv1001 k"
      if Word.where('id_value >-1').limit(1).length >0
        #  logger.info "rwv1001 l"
        max_prime = Word.maximum('word_prime')
        max_id = Word.maximum('id_value')
        #   logger.info "rwv1001 m"
        # logger.info "max_prime = #{max_prime}, max_id = #{max_id} "
      else
        max_id = 0
        max_prime = 2
      end

      new_words = Word.where(id_value: 0)
      new_id = max_id + 1
      new_prime = GetNextPrime(max_prime)


      new_words_str = []
      new_words.each do |new_word|
        new_words_str << "(\'#{new_word.word_name}\',#{new_id}, #{new_prime})"
        new_prime = GetNextPrime(new_prime)
        new_id = new_id + 1
      end
      if new_words.length > 0

        #sql = "REPLACE INTO words (word_name, id_value, word_prime) VALUES #{new_words_str.to_a.join(', ')}"


        sql = "UPDATE words AS w SET id_value = c.id_value, word_prime= c.word_prime FROM (VALUES  #{new_words_str.to_a.join(', ')}) as c(word_name, id_value, word_prime)
        where c.word_name = w.word_name;"
        # logger.info "sql = #{sql}"
        #   logger.info "rwv1001 o"
        sql_save(sql)
        #   logger.info "rwv1001 v"
      else
        logger.info "new_words is empty"
      end

      new_word_list = "(#{@word_set.to_a.join(', ')})"
      new_words_from_db_str = "word_name IN #{new_word_list}"
      #     logger.info "new_words_from_db_str = #{new_words_from_db_str}"
      new_words_from_db = Word.where("word_name IN #{new_word_list}")
      new_words_from_db.each do |new_word_from_db|
        @word_hash[new_word_from_db.word_name] = new_word_from_db.id_value
        @word_prime_hash[new_word_from_db.word_name] = new_word_from_db.word_prime

      end
    end
  end

  def ProcessSentences(par_sentences, result_page_id)

    @sentence_inserts = []
    @word_inserts = Set.new
    @word_singleton_inserts = []
    @word_pairs_inserts = []
    @word_set = Set.new
    @word_hash = Hash.new
    @word_prime_hash = Hash.new
    @word_entries = Set.new

    @sentence_objects = nil

    par_sentences.each do |par_sentence|

      par_sentence[:sentences].each do |sentence|
        ProcessSentence(sentence, par_sentence[:paragraph_id])
      end
    end

    AddSentencesAndWords()

    @sentence_objects.each do |sentence_obj|
      ProcessSingletonPairs(sentence_obj, result_page_id)
    end
    AddSingletonPairs()
  end


  def AddSingletonPairs()
    logger.info "AddSingletonPairs"
    if @word_singleton_inserts.length > 0
      sql = "INSERT INTO word_singletons (word_id, sentence_id, result_page_id, paragraph_id) VALUES #{@word_singleton_inserts.join(', ')}"
      # logger.info "sql = #{sql}"
      sql_save(sql)
    else
      logger.info "@word_singleton_inserts is empty"
    end
    if @word_pairs_inserts.length > 0
      sql = "INSERT INTO word_pairs (word_multiple, separation, result_page_id,sentence_id) VALUES #{@word_pairs_inserts.join(', ')}"
      # logger.info "sql = #{sql}"
      sql_save(sql)
    else
      logger.info "@word_pairs_inserts is empty"
    end


  end


  def ProcessSentence(sentence, paragraph_id)
    #@sentence_inserts.push "(\"#{sentence.gsub('"', '\"')}\",#{paragraph_id})"
    logger.info "************ ProcessSentence #{sentence}"
    @sentence_inserts.push "(\'#{sentence.gsub("'", "''")}\',"+((sentence.accented)? "TRUE,\'#{sentence.deaccent.gsub("'", "''")}\'," : "FALSE,\'\',")+"#{paragraph_id})" # psql


    sentence = sentence.deaccent.gsub(/[^a-zA-Z0-9α-ω]/, ' ')
    word_list = sentence.split(' ')

    word_list.each do |word|
      # logger.info "#{word_count}, Word: #{word}"

      #   logger.info "v2"
      if word.length > 0
        #      logger.info "v3"
        @word_entries.add "(\'#{word.downcase.deaccent}\', 0, 0)"
        @word_set.add("\'#{word.downcase.deaccent}\'")
      end
      #  logger.info "v14"
    end
  end

  def ProcessSingletonPairs(sentence_obj, result_page_id)

    sentence = sentence_obj.content.deaccent.gsub(/[^a-zα-ωA-Z0-9]/, ' ')
    word_list = sentence.downcase.split(' ')
    #   TimeLogger("03")
    word_inserts = []
    word_singleton_set = Set.new
    word_list.each do |word|
      word_singleton_set.add(word.downcase.deaccent)
    end

    #  logger.info "word_set length = #{word_set.length}, word_array = #{word_array}"
    word_singleton_set.each do |word|

      @word_singleton_inserts.push "(#{@word_hash[word]},#{sentence_obj.id}, #{result_page_id}, #{sentence_obj.paragraph_id})"
    end
    #  logger.info "@word_singleton_inserts = #{@word_singleton_inserts}"


    for i in 0..word_list.length-1
      word_1 = @word_prime_hash[word_list[i]]
      if word_1 == nil
        logger.info "!!!!!!!!!!!!!!!! word_1 is nil for #{word_list[i]}"
      end

      if i<word_list.length-1
        for j in (i+1) .. [i+@max_separation, word_list.length-1].min
          word_2 = @word_prime_hash[word_list[j]]
          if word_2 == nil
            logger.info "!!!!!!!!!!!!!!!! word_2 is nil for #{word_list[j]}"
            logger.info "@word_prime_hash = #{@word_prime_hash.inspect}"
          end
          #    logger.info "word_list[i] = #{word_list[i]}, word_list[j] = #{word_list[j]}, @word_prime_hash = [#{ @word_prime_hash[word_list[i]]},#{ @word_prime_hash[word_list[j]]}]"
          @word_pairs_inserts.push "(#{word_1 * word_2},#{j-i}, #{result_page_id}, #{sentence_obj.id})"
        end
      end
    end

    #   TimeLogger("05")
    #  logger.info "ProcessSentence end"


  end

  def ProcessSentenceOld(sentence, result_page_id, paragraph_id)
    logger.info "ProcessSentence begin"
    #logger.info "original sentence: #{sentence}"

    #TimeLogger("01")

    sentence_object = Sentence.new
    sentence_object.content = sentence
    sentence_object.paragraph_id = paragraph_id
    sentence_object.save
    word_count=1
    word_array = Array.new
    word_set = Set.new
    sentence = sentence.gsub(/[^a-zα-ωA-Z0-9]/, ' ')
    # TimeLogger("02")
    #  logger.info "sentence without punctuation: #{sentence}"
    word_list = sentence.split(' ')
    #  logger.info "v1"
    sentence.split(' ').each do |word|
      # logger.info "#{word_count}, Word: #{word}"
      word_count=word_count+1
      #   logger.info "v2"
      if word.length > 1
        #      logger.info "v3"
        word_object = Word.find_by_word_name(word.downcase)
        #     logger.info "v4"
        if word_object == nil
          #      logger.info "v5"
          word_object = Word.new

          word_object.word_name = word.downcase
          if Word.exists?
            #       logger.info "v6"
            #     logger.info "last word is #{Word.last.word_prime}"
            possible_prime = Word.last.word_prime

            #        logger.info "v7 #{possible_prime}"
            possible_prime = possible_prime + 2
            #        logger.info "v7a #{possible_prime}"
            while @@primes.prime?(possible_prime) == false
              possible_prime = possible_prime + 2
              #       logger.info "v8"
            end

          else
            #       logger.info "v9"
            possible_prime = 3

          end
          #    logger.info "v10"
          word_object.word_prime = possible_prime
          word_object.save
        end
        #  logger.info "v11"
        word_array << word_object
        #  logger.info "v12"
        word_set.add(word_object.id)
        #    logger.info "v13"
      end
      #  logger.info "v14"
    end
    #   TimeLogger("03")
    word_inserts = []

    #  logger.info "word_set length = #{word_set.length}, word_array = #{word_array}"
    word_set.each do |word_id|
      word_inserts.push "(#{word_id},#{sentence_object.id}, #{result_page_id})"
      # word_singleton = WordSingleton.new
      #  word_singleton.word_id = word_id
      #  word_singleton.sentence_id = sentence_object.id
      #  word_singleton.result_page_id = result_page_id
      #   word_singleton.save
    end
    if word_inserts.length > 0
      sql = "INSERT INTO word_singletons (word_id, sentence_id, result_page_id) VALUES #{word_inserts.join(', ')}"
      # logger.info "sql = #{sql}"
      sql_save(sql)
    end
    # TimeLogger("04")
    pair_inserts = []

    for i in 0..word_array.length-1
      word_1 = word_array[i]


      if i<word_array.length-1
        for j in (i+1) .. [i+@max_separation, word_array.length-1].min
          word_2 = word_array[j]
          #word_pair = WordPair.new
          # word_pair.word_multiple = word_1.word_prime * word_2.word_prime
          # word_pair.separation = j-i
          # word_pair.result_page_id = result_page_id
          # word_pair.sentence_id = sentence_object.id
          pair_inserts.push "(#{word_1.word_prime * word_2.word_prime},#{j-i}, #{result_page_id}, #{sentence_object.id})"
          # word_pair.save
          #        word_pair.save if not WordPair.exists?(:word_multiple => word_pair.word_multiple, :result_page_id => result_page_id, :sentence_id => sentence_object.id)
        end
      end
    end
    if pair_inserts.length > 0
      sql = "INSERT INTO word_pairs (word_multiple, separation, result_page_id,sentence_id) VALUES #{pair_inserts.join(', ')}"
      # logger.info "sql = #{sql}"
      sql_save(sql)
    end

    #   TimeLogger("05")
    logger.info "ProcessSentence end"
  end

  def ProcessParagraphs(paragraphs, result_page_id, flow_str)
    logger.info "ProcessParagraphs begin, paragraphs length = #{paragraphs.length}"
    paragraph_count = 0
    @paragraph_inserts =[]
    par_inserts = []
    paragraph_block_num = 100

    for par_count in 0..paragraphs.length-1
      par = paragraphs[par_count]
      logger.info "ProcessParagraphs, result_page_id = #{result_page_id}, par = #{par}"

      if @max_paragraph_number<0 || paragraph_count<@max_paragraph_number
        par_text = par.text
        par_ok = true
        #the code below is to deal with a bug in reading paragraphs
        if par_count < (paragraphs.length-2)
          par_index = par_text.index(paragraphs[par_count+1].text)
          if par_index != nil and par_text.index(paragraphs[par_count+2].text) !=nil
            par_text = par_text[0..par_index-1]
            par_ok = false
          end
        end
        @last_paragraph = par_text
        paragraph_count=paragraph_count+1
        #@paragraph_inserts.push "(\"#{par_text.gsub('"', '\"')}\",#{result_page_id})"
        logger.info "** par = #{par.inspect} "
        if par.attribute("class") != nil and par.attribute("class").value == flow_str and par_inserts.length >0
          par_inserts[-1] = par_inserts[-1] + " " + par_text
        else
          if par.name=="p" or par_ok == false
            par_inserts.concat( par_text.split(/[\r\n]{4,}+/).map{|split_par| split_par.split(/\n{2,}+/).map{|sp| sp.gsub(/\r\n/,' ').gsub(/\n/,' ')}}.flatten.select{|p| p.length >0})
          else
            columns =  par.children
            if columns.length >1
              par_inserts << "<table><tr><td>" + columns.select{|cc| cc.name == "td"}.map{|td| td.text}.join('</td><td>') + '</td></tr></table>'.gsub(/\r\n/,' ')

            else
              par_inserts.concat( par_text.split(/[\r\n]{4,}+/).map{|split_par| split_par.split(/\n{2,}+/).map{|sp| sp.gsub(/\r\n/,' ').gsub(/\n/,' ')}}.flatten.select{|p| p.length >0})
            end


          end


        end


        if par_inserts.length>=paragraph_block_num
          @paragraph_inserts = par_inserts.map{|pi|  "(\'#{pi.gsub("'", "''")}\',"+((pi.accented)? "TRUE,\'#{pi.deaccent.gsub("'", "''")}\'," : "FALSE,\'\',")+"#{result_page_id})"}
          par_inserts = []
          save_paragraphs(result_page_id)

        end
      end

    end
    if par_inserts.length > 0
      @paragraph_inserts = par_inserts.map{|pi|  "(\'#{pi.gsub("'", "''")}\',"+((pi.accented)? "TRUE,\'#{pi.deaccent.gsub("'", "''")}\'," : "FALSE,\'\',")+"#{result_page_id})"}
      save_paragraphs(result_page_id)


    end
    logger.info "ProcessParagraphs end"

  end

  def save_paragraphs(result_page_id)
     logger.info "rwv1001 a"
    if Paragraph.exists?()
         logger.info "rwv1001 b"
      max_id = Paragraph.maximum('id')
      logger.debug ""
    else
      max_id = 0;
    end
    logger.debug ""
    sql = %Q"INSERT INTO paragraphs (content, accented, deaccented_content, result_page_id) VALUES #{@paragraph_inserts.join(', ')}"
    # logger.info "sql = #{sql}"
    sql_save(sql)
     logger.info "rwv1001 c"
    paragraphs = Paragraph.where("id > #{max_id}").order("id asc")
     logger.info "rwv1001 d"
    par_sentences = []
    paragraphs.each do |paragraph|
      par_sentence = Hash.new
      par_content = paragraph.content
      matches = par_content.to_enum(:scan, /\([^\)]*\)/).map {Regexp.last_match}
      period_indices = matches.map{|match| match.to_s.to_enum(:scan, /\./).map {Regexp.last_match}.map{|period_match| match.offset(0)[0]+period_match.offset(0)[0] }}.flatten.sort.reverse
      period_indices.each{|pi| par_content[pi]= 'a¶a'}
      matches2 = par_content.to_enum(:scan, /\[[^\]]*\]/).map {Regexp.last_match}
      period_indices2 = matches2.map{|match| match.to_s.to_enum(:scan, /\./).map {Regexp.last_match}.map{|period_match| match.offset(0)[0]+period_match.offset(0)[0] }}.flatten.sort.reverse
      period_indices2.each{|pi| par_content[pi]= 'a¶a'}

      matches3 = par_content.to_enum(:scan, /\.\s*[a-z0-9]/).map {Regexp.last_match}
      period_indices3 = matches3.map{|match| match.to_s.to_enum(:scan, /\./).map {Regexp.last_match}.map{|period_match| match.offset(0)[0]+period_match.offset(0)[0] }}.flatten.sort.reverse
      period_indices3.each{|pi| par_content[pi]= 'a¶a'}
      paragraph_sentences = par_content.split('.').map{|sentence|sentence.gsub(/a¶a/,'.')<<"."}
      if par_content[-1] != "."
        paragraph_sentences[-1]=paragraph_sentences[-1][0..-2]
      end
      
      par_sentence[:sentences] = paragraph_sentences
      logger.info "*** par_sente nce #{par_sentence.inspect} "
      par_sentence[:paragraph_id] = paragraph.id
      par_sentences.push(par_sentence)
    end
       logger.info "rwv1001 e"
    ProcessSentences(par_sentences, result_page_id)
      logger.info "rwv1001 ee"
    @paragraph_inserts =[]


  end

  # @param [String] url
  # @param [String] base_url
  # @param [number] current_level
  # @return [Object]


  def grab_page(url, current_level, parent_id)
    logger.info "grab_page begin"
    new_crawler_page = 0
    # logger.info "AA parent_id = #{parent_id}, level = #{current_level}"
    if (@current_page_store<@max_page_store or @max_page_store<0)
      new_parent_id = 0
      crawl_number =0
      last_slash = url.rindex("/")
      last_period = url.rindex(".")
      last_hash = url.rindex("#")
      if last_hash != nil
        url = url[0, last_hash]
      end
      if last_period == nil
        logger.info "01c"
        return
      end

      if last_slash < url.length-1
        if last_period > last_slash then
          file_name = url[last_slash+1, url.size]
          base_url = url[0, last_slash+1]
        else
          logger.info "01a"
          return
          file_name = 'index.html'
          base_url = url + '/'
        end
      else
        logger.info "01b"
        return
        file_name = 'index.html'
        base_url = url
      end
      url = base_url + file_name


      logger.info "process_hash url: #{url}, base_url: #{base_url}, file_name: #{file_name}, level: #{current_level}"
      next_level = current_level+1
      new_pages = Set.new

      second_attempt = false
      if @filter.length == 0 or url !~ /#{@filter}/
        if CrawlerPage.exists?(URL: url, domain_crawler_id: self.id)
          new_crawler_results = CrawlerPage.where(URL: url, domain_crawler_id: self.id)
          new_crawler_page = new_crawler_results.first
                 logger.info "ProcessPage 07 new_crawler_results length is #{new_crawler_results.length}"
        else
          new_crawler_page = CrawlerPage.new
          new_crawler_page.URL = url
          new_crawler_page.name = ""
          new_crawler_page.domain_crawler_id = self.id
                logger.info "ProcessPage 08"
        end

        begin
          doc = Nokogiri::HTML(open(url))
        rescue Exception => e
          second_attempt = true
          logger.info "Couldn't read \"#{ url }\": #{ e }"
          logger.info "let's sleep for 4ss"
          sleep(4)

        end
       begin
          if second_attempt == true
            logger.info "2nd attempt read"
            doc = Nokogiri::HTML(open(url))

          end
          @page_count = @page_count +1
          logger.info "grab_page #{@page_count}"


          logger.info "let's sleep for 5s"
          sleep(5)
          crawler_pagea = CrawlerPage.where(URL: url)
          read_page = true
          if crawler_pagea.length >0
            read_page = false
          end


          # hash_value = Digest::MD5.hexdigest(body)
          #      logger.info "ProcessPage 03"
          @current_page_store = @current_page_store +1


          #     logger.info "Number of paragraphs =  #{paragraphs.length}"
          #logger.info "Paragraph 0 is #{paragraphs[0].text}"
          #logger.info "Paragraph 1 is #{paragraphs[1].text}"
          #logger.info "Paragraph 2 is #{paragraphs[2].text}"
          #logger.info "Paragraph 3 is #{paragraphs[3].text}"
          content = doc.to_html
          fix_html(content)
          hash_value = Digest::MD5.hexdigest(content)
          #   logger.info "hash_value is #{hash_value}"

          result_page = ResultPage.find_by_hash_value(hash_value)

              logger.info "ProcessPage 05"
          if (result_page==nil or @always_process) and content.length > 0
                logger.info "ProcessPage 06"
            result_page = ResultPage.new
            result_page.content = content
            result_page.hash_value = hash_value
            result_page.save

            #ProcessParagraphs(paragraphs, result_page.id)
          else

            logger.info "Page already processed or empty: #{url}, paragraphs.length = #{paragraphs.length}"
          end


                logger.info "ProcessPage 09"
          logger.info "new_crawler_page: #{new_crawler_page.inspect}"

          new_crawler_page.name = file_name
          new_crawler_page.result_page_id = result_page.id
          new_crawler_page.download_date = Date.today


                  logger.info "ProcessPage 10"

          new_crawler_page.save
          new_parent_id = new_crawler_page.id

        result_page.crawler_page_id = new_crawler_page.id
        result_page.save

          if @first_page_id == 0
            @first_page_id = new_crawler_page.id
            self.crawler_page_id = @first_page_id
            #      logger.info "Setting first crawler page to #{@first_page_id}"
          else
            logger.info "First crawler page not set, already #{@first_page_id}"
          end



               # logger.info "Saved url #{url}"


          #       logger.info "ProcessPage 3"
          if new_crawler_page.depth < @max_level
            links = doc.xpath('//a')
            links.each do |item|

              logger.info "Href1: #{item['href'].inspect}, #{item['href'].class}"

              href_str = item["href"]
              if href_str.nil? or href_str =~ /^javascript/ or href_str =~ /^mailto:/
                logger.info "Nil case: #{href_str}"
                href_str = ""
              end
              if href_str =~/pdf$/ or href_str =~ /wav$/
                href_str = ""
              end
              if href_str =~ /^#{base_url}/
                logger.info "we have a match for #{href_str}"
                href_str.sub! base_url, ''
                logger.info "Updated: #{href_str}"
              end
              last_hash = href_str.rindex("#")
              if last_hash !=nil
                if last_hash >0
                  href_str = href_str[0..last_hash-1]
                else
                  href_str = ""
                end
              end

              if href_str =~ /^http:/ or href_str =~ /^https:/
                logger.info "wrong domain: #{href_str}"
                href_str = ""
              end
              new_url = (base_url+href_str).gsub(/\/[^\.\/]+\/\.\./, "")
              logger.info "base_url+href_str =  #{base_url+href_str}"

              if href_str.length >0 and crawl_number < @max_crawl_number  and new_url !~ /#{@filter}/
                #   match_value = get_match_value(new_url, url)
                if CrawlerPage.exists?(URL: new_url, domain_crawler_id: self.id)== false

                  @current_pages[new_url] ||= next_level
                  new_pages.add(new_url)
                  crawl_number=crawl_number+1
                  aref_crawler_page = CrawlerPage.new
                  aref_crawler_page.name = ""
                  aref_crawler_page.URL = new_url
                  #   aref_crawler_page.match_value = match_value
                  aref_crawler_page.domain_crawler_id = self.id
                  aref_crawler_page.parent_id = new_parent_id
                  aref_crawler_page.save
                  logger.info "aref_crawler_page: #{aref_crawler_page.inspect}"
                else
                  another_crawler_page = CrawlerPage.where(URL: new_url, domain_crawler_id: self.id).first
                  another_parent = another_crawler_page.parent
                  logger.info "another_crawler_page: #{another_crawler_page.inspect}"
                  logger.info "new_crawler_page: #{new_crawler_page.inspect}"
                  if another_crawler_page.depth > new_crawler_page.depth+1
                    logger.info "updating parent"
                    another_crawler_page.parent_id = new_parent_id
                    another_crawler_page.save
                    if another_crawler_page.result_page_id == nil
                      new_pages.add(new_url)
                    end
                  end
                  #  if another_parent != nil
                  #  another_parent_url = another_parent.URL
                  #   if get_match_value(new_url, another_parent_url) < match_value
                  #    another_crawler_page.parent_id = new_parent_id
                  #   another_crawler_page.match_value = match_value
                  #          another_crawler_page.save
                  # end
                  # end
                end
              end
            end
          end
            #    logger.info "ProcessPage 13"
            #      logger.info "ProcessPage 4"

        rescue Exception => e
          logger.info "2nd attempt - Couldn't read \"#{ url }\": #{ e }"
          if new_crawler_page.result_page_id != nil
            if new_crawler_page.result_page_id< 0
              new_crawler_page.result_page_id = new_crawler_page.result_page_id - 1
            end
          else
            new_crawler_page.result_page_id = -1
          end
          new_crawler_page.save
        end


      old_parent_id = parent_id

      new_process_pages = []


      new_pages.each do |url|
        parent_id = new_parent_id
        grab_page(url, next_level, parent_id)
      end if next_level < @max_level
      parent_id = old_parent_id
      end
    end

  end

  def ProcessPage(url, current_level, parent_id, flow_str)
    logger.info "ProcessPage begin"
    new_crawler_page = 0
    # logger.info "AA parent_id = #{parent_id}, level = #{current_level}"
    if (@current_page_store<@max_page_store or @max_page_store<0)
      new_parent_id = 0
      crawl_number =0
      last_slash = url.rindex("/")
      last_period = url.rindex(".")
      last_hash = url.rindex("#")
      if last_hash != nil
        url = url[0, last_hash]
      end
      if last_period == nil
        logger.info "01c"
        return
      end

      if last_slash < url.length-1
        if last_period > last_slash then
          file_name = url[last_slash+1, url.size]
          base_url = url[0, last_slash+1]
        else
          logger.info "01a"
          return
          file_name = 'index.html'
          base_url = url + '/'
        end
      else
        logger.info "01b"
        return
        file_name = 'index.html'
        base_url = url
      end
      url = base_url + file_name


      logger.info "process_hash url: #{url}, base_url: #{base_url}, file_name: #{file_name}, level: #{current_level}"
      next_level = current_level+1
      new_pages = Set.new

      second_attempt = false

      if CrawlerPage.exists?(URL: url, domain_crawler_id: self.id)
        new_crawler_results = CrawlerPage.where(URL: url, domain_crawler_id: self.id)
        new_crawler_page = new_crawler_results.first
        #        logger.info "ProcessPage 07 new_crawler_results length is #{new_crawler_results.length}"
      else
        new_crawler_page = CrawlerPage.new
        new_crawler_page.URL = url
        new_crawler_page.name = ""
        new_crawler_page.domain_crawler_id = self.id
        #       logger.info "ProcessPage 08"
      end

      begin
        doc = Nokogiri::HTML(open(url))
      rescue Exception => e
        second_attempt = true
        logger.info "Couldn't read \"#{ url }\": #{ e }"
        logger.info "let's sleep for 4ss"
        sleep(4)

      end
   #   begin
        if second_attempt == true
          logger.info "2nd attempt read"
          doc = Nokogiri::HTML(open(url))

        end
        @page_count = @page_count +1
        logger.info "ProcessPage #{@page_count}"


        logger.info "let's sleep for 5s"
        sleep(5)
        crawler_pagea = CrawlerPage.where(URL: url)
        read_page = true
        if crawler_pagea.length >0
          read_page = false
        end


        # hash_value = Digest::MD5.hexdigest(body)
        #      logger.info "ProcessPage 03"
        @current_page_store = @current_page_store +1
        paragraphs = doc.xpath('//td')


        #     logger.info "Number of paragraphs =  #{paragraphs.length}"
        #logger.info "Paragraph 0 is #{paragraphs[0].text}"
        #logger.info "Paragraph 1 is #{paragraphs[1].text}"
        #logger.info "Paragraph 2 is #{paragraphs[2].text}"
        #logger.info "Paragraph 3 is #{paragraphs[3].text}"
        content = ""
        paragraphs.each do |par|
          #logger.info "par content is #{par.text}"
          #content << "<p>" << ActionController::Base.helpers.strip_tags(par.text) << "</p>\n\n"
          #par_text = Nokogiri::HTML(par).xpath('//text()').map(&:text).join(' ')
          #content << "<p>" << par.text.gsub(/<[^>]*>/, " ") << "</p>\n\n"
          content << "<p>" << Digest::MD5.hexdigest(par.xpath('//text()').map(&:text).join(' ')) << "</p>\n\n"
        end
        #     logger.info "ProcessPage 04"
        #logger.info "body content is #{content}"

        hash_value = Digest::MD5.hexdigest(content)
        #   logger.info "hash_value is #{hash_value}"
        result_page = ResultPage.find_by_hash_value(hash_value)

        #     logger.info "ProcessPage 05"
        if (result_page==nil or @always_process) and paragraphs.length > 0
          #     logger.info "ProcessPage 06"
          result_page = ResultPage.new
          # result_page.content = content
          result_page.hash_value = hash_value
          result_page.save

          ProcessParagraphs(paragraphs, result_page.id, flow_str)
        else

          logger.info "Page already processed or empty: #{url}, paragraphs.length = #{paragraphs.length}"
        end


        #      logger.info "ProcessPage 09"
        logger.info "new_crawler_page: #{new_crawler_page.inspect}"

        new_crawler_page.name = file_name
        new_crawler_page.result_page_id = result_page.id
        new_crawler_page.download_date = Date.today



        if parent_id!=0
          #new_crawler_page.parent_id = parent_id *********************
        end
        #        logger.info "ProcessPage 10"

        new_crawler_page.save
        new_parent_id = new_crawler_page.id

      result_page.crawler_page_id = new_crawler_page.id
      result_page.save


        if @first_page_id == 0
          @first_page_id = new_crawler_page.id
          self.crawler_page_id = @first_page_id
          #      logger.info "Setting first crawler page to #{@first_page_id}"
        else
          logger.info "First crawler page not set, already #{@first_page_id}"
        end
        #       logger.info "ProcessPage 11"

        #    logger.info "ProcessPage 12"


        #      logger.info "Saved url #{url}"


        #       logger.info "ProcessPage 3"
        if new_crawler_page.depth < @max_level
          links = doc.xpath('//a')
          links.each do |item|

            logger.info "Href1: #{item['href'].inspect}, #{item['href'].class}"

            href_str = item["href"]
            if href_str.nil? or href_str =~ /^javascript/ or href_str =~ /^mailto:/
              logger.info "Nil case: #{href_str}"
              href_str = ""
            end
            if href_str =~/pdf$/ or href_str =~ /wav$/
              href_str = ""
            end
            if href_str =~ /^#{base_url}/
              logger.info "we have a match for #{href_str}"
              href_str.sub! base_url, ''
              logger.info "Updated: #{href_str}"
            end
            last_hash = href_str.rindex("#")
            if last_hash !=nil
              if last_hash >0
                href_str = href_str[0..last_hash-1]
              else
                href_str = ""
              end
            end

            if href_str =~ /^http:/ or href_str =~ /^https:/
              logger.info "wrong domain: #{href_str}"
              href_str = ""
            end
            new_url = (base_url+href_str).gsub(/\/[^\.\/]+\/\.\./, "")
            logger.info "base_url+href_str =  #{base_url+href_str}"

            if href_str.length >0 and crawl_number < @max_crawl_number and new_url !~ /#{@filter}/
              #   match_value = get_match_value(new_url, url)
              if CrawlerPage.exists?(URL: new_url, domain_crawler_id: self.id)== false

                @current_pages[new_url] ||= next_level
                new_pages.add(new_url)
                crawl_number=crawl_number+1
                aref_crawler_page = CrawlerPage.new
                aref_crawler_page.name = ""
                aref_crawler_page.URL = new_url
                #   aref_crawler_page.match_value = match_value
                aref_crawler_page.domain_crawler_id = self.id
                aref_crawler_page.parent_id = new_parent_id
                aref_crawler_page.save
                logger.info "aref_crawler_page: #{aref_crawler_page.inspect}"
              else
                another_crawler_page = CrawlerPage.where(URL: new_url, domain_crawler_id: self.id).first
                another_parent = another_crawler_page.parent
                logger.info "another_crawler_page: #{another_crawler_page.inspect}"
                logger.info "new_crawler_page: #{new_crawler_page.inspect}"
                if another_crawler_page.depth > new_crawler_page.depth+1
                  logger.info "updating parent"
                  another_crawler_page.parent_id = new_parent_id
                  another_crawler_page.save
                  if another_crawler_page.result_page_id == nil
                    new_pages.add(new_url)
                  end
                end
                #  if another_parent != nil
                #  another_parent_url = another_parent.URL
                #   if get_match_value(new_url, another_parent_url) < match_value
                #    another_crawler_page.parent_id = new_parent_id
                #   another_crawler_page.match_value = match_value
                #          another_crawler_page.save
                # end
                # end
              end
            end
          end
        end
          #    logger.info "ProcessPage 13"
          #      logger.info "ProcessPage 4"
=begin
      rescue Exception => e
        logger.info "2nd attempt - Couldn't read \"#{ url }\": #{ e }"
        if new_crawler_page.result_page_id != nil
          if new_crawler_page.result_page_id< 0
            new_crawler_page.result_page_id = new_crawler_page.result_page_id - 1
          end
        else
          new_crawler_page.result_page_id = -1
        end
        new_crawler_page.save
      end
=end
      old_parent_id = parent_id

      new_process_pages = []


      new_pages.each do |url|


        parent_id = new_parent_id

        ProcessPage(url, next_level, parent_id, flow_str)

      end if next_level < @max_level
      parent_id = old_parent_id
    end
  end

  def get_match_value(new_url, parent_url)
    new_url_tokens = new_url.split('/')
    parent_url_tokens = parent_url.split('/')
    match_count = 0
    while match_count< new_url_tokens.length and new_url_tokens[match_count] == parent_url_tokens[match_count]
      match_count= match_count+1
    end
    return match_count


  end

  def deaccent_domain(crawler_page)
    sentence_block_size = 100
    sentence_id_start = 1
    sentences = Sentence.where("id>=? and id < ?", sentence_id_start, sentence_id_start + sentence_block_size )
    while sentences.length > 0
      logger.info "sentence_id_start = #{sentence_id_start}"
    sentences.each do |sentence|
      if sentence.content.accented
        sentence.accented = true
        sentence.deaccented_content = sentence.content.deaccent
        sentence.save
      end
    end
    sentence_id_start = sentence_id_start + sentence_block_size
    sentences = Sentence.where("id>=? and id < ?", sentence_id_start, sentence_id_start + sentence_block_size )
    end

    paragraph_block_size = 30
    paragraph_id_start = 1
    paragraphs = Paragraph.where("id>=? and id < ?", paragraph_id_start, paragraph_id_start + paragraph_block_size )
    while paragraphs.length > 0
      logger.info "paragraph_id_start = #{paragraph_id_start}"
      paragraphs.each do |paragraph|
        if paragraph.content.accented
          paragraph.accented = true
          paragraph.deaccented_content = paragraph.content.deaccent
          paragraph.save
        end
      end
      paragraph_id_start = paragraph_id_start + paragraph_block_size
      paragraphs = Paragraph.where("id>=? and id < ?", paragraph_id_start, paragraph_id_start + paragraph_block_size )
    end




  end


  def reorder_pages(crawler_page)
    @get_page_list_count = 0
    #  logger.info "**************************reorder_pages: #{crawler_page.inspect}"
    ids = [crawler_page.id]
    ids.concat(crawler_page.descendant_ids).sort!
    page_list = [crawler_page]
    page_list.concat(get_page_list(crawler_page))
    default_domain_crawler_id = crawler_page.domain_crawler_id
    logger.info "************page_listinspect"
    logger.info "= #{6.times.map { |ii| page_list[ii].inspect }}"
    if page_list.length == ids.length
      id_conversion = Hash.new;

      page_list.size.times.each { |ii| id_conversion[page_list[ii].id] = ids[ii] }
      self.crawler_page_id = id_conversion[self.crawler_page_id]?id_conversion[self.crawler_page_id]:self.crawler_page_id
      self.save

      del_str = "DELETE FROM crawler_pages WHERE id IN (#{ids.join(', ')})"
      update_values = page_list.map do |pl|
        "(#{id_conversion[pl.id]}, #{(pl.result_page_id) ? (pl.result_page_id) : 'NULL'}, '#{pl.URL}', '#{pl.name}', '#{(pl.ancestry) ? pl.ancestry.split('/').map { |id| (id_conversion[id.to_i]? id_conversion[id.to_i]:id)  }.join('/') : nil}', #{(pl.domain_crawler_id ? pl.domain_crawler_id : default_domain_crawler_id)}, '#{(pl.download_date ? pl.download_date : Date.today)}')"
      end
      logger.info "****del_str = #{del_str}"
      update_crawler_page_str = "INSERT INTO crawler_pages (id, result_page_id, \"URL\", name, ancestry, domain_crawler_id, download_date) VALUES #{update_values.join(', ')}"
      logger.info "****update_crawler_page_str = #{update_crawler_page_str}"
      result_page_hash = Hash.new
      page_list.each { |pl| result_page_hash[pl.result_page_id] = {"crawler_page_id" => id_conversion[pl.id]} if pl.result_page_id and pl.result_page_id>0 }
      result_page_hash.delete(-1)
      logger.info "************result_page_hash = #{result_page_hash.inspect}"
      @connection = ActiveRecord::Base.connection
      @connection.execute(del_str)
      @connection.execute(update_crawler_page_str)
      ResultPage.update(result_page_hash.keys, result_page_hash.values)
      ret_value = id_conversion[crawler_page.id]

      return ret_value

    else
      logger.info "ERROR!!!! page_list.length =#{page_list.length}, ids.length =#{ids.length}"
      logger.info "page_list = #{page_list.map { |pl| pl.id }.sort}"
      logger.info "ids = #{ids}"
    end
    update_str = ""

  end

  def get_page_list(crawler_page)

    # logger.info "get_page_list: #{crawler_page.inspect}"
    ret_value = []
    if crawler_page.is_childless?

      #   logger.info "get_page_list Is childless: #{ret_value.inspect}"
    else

      crawler_page.children.arrange(:order => :name).map { |key, val| key }.each do |child|
        #     logger.info "get_page_list child: #{child.inspect}"
        ret_value<<child
        #     logger.info "get_page_list ret_value is: #{ret_value.inspect}"

        ret_value.concat(get_page_list(child))
      end
    end
    #  logger.info "get_page_list ret_value is: #{ret_value.inspect}"
    return ret_value

  end



  def fix_domain
    initialize_crawl
    bad_pages = CrawlerPage.where(["(result_page_id  <0 or result_page_id is NULL) and domain_crawler_id = ?", self.id]).order("id asc")
    orig_num_of_bad_pages = bad_pages.length
    bad_pages.each do |bad_page|
      logger.info "fixing bad page: #{bad_page}"
      ProcessPage(bad_page.URL, 0, bad_page.parent_id)
    end
    afterwards_bad_pages = CrawlerPage.where(["(result_page_id  <0 or result_page_id is NULL) and domain_crawler_id = ?", self.id]).order("id asc")
    afterwards_num_of_bad_pages = afterwards_bad_pages.length
    result_str = "Number of bad pages before fixing: #{orig_num_of_bad_pages}. Number of bad pages after fixing:#{afterwards_num_of_bad_pages}."
    return result_str
  end

  def initialize_crawl
    @previous_time =0
    @a=0

    @max_page_store = -1
    @max_crawl_number = 10000
    @max_paragraph_number =-1
    @max_separation = 10
    @current_page_store = 0
    @last_paragraph = ""

    @first_page_id = 0
    @max_level = 4
    @always_process = false
    @connection = ActiveRecord::Base.connection
    @page_count = 0
    @current_pages = Hash.new()
    @current_pages[domain_home_page] = 0

    @parent_id = 0
    @current_level = 0

  end

  def grab_domain(filter)
    logger.info "start grab for URL #{@domain_home_page}"
    @filter = filter
    initialize_crawl
    grab_page(domain_home_page, @current_level, @parent_id)
    page= CrawlerPage.find_by_id(@first_page_id)
    if page != nil
      first_page_id = reorder_pages(page.root)
    else
      first_page_id = 0
    end
    return first_page_id
  end

  def analyse_page(rp, flow_str)
    doc = Nokogiri::HTML(rp.content)

    paragraphs =  doc.xpath('//tr') + doc.xpath('//p')
    body = doc.xpath('//body')
    if paragraphs.text.length < 0.50 *body.text.length
      content = '<p>'<< body.text.split(/[\r\n]{4,}+/).join('<\p> <p>')<< '<\p>'
      doc = Nokogiri::HTML(content)
      paragraphs = doc.xpath('//p')
    end
    ProcessParagraphs(paragraphs, rp.id, flow_str)

  end

  def analyse_domain(user_id, flow_str)
    initialize_crawl
    logger.info "start analyse_domain user_id = #{user_id}, flow_str = #{flow_str}"
    crawler_ranges =  CrawlerRange.where(:user_id => user_id).map{|cr| [cr.begin_id, cr.end_id]}

    if crawler_ranges.length >0


      range_strs = crawler_ranges.map{|cr| "(rp.crawler_page_id >= #{cr[0]} AND rp.crawler_page_id <= #{cr[1]})"}
      sql_str = "SELECT * FROM result_pages rp WHERE #{range_strs.join(' OR ')}"
      logger.info "analyse_domain sql_str = #{sql_str}"

      result_pages = ResultPage.find_by_sql(sql_str);

     # result_pages.each{|rp| WordSingleton.where(:result_page_id => rp.id).destroy_all}
      result_pages.each{|rp| ActiveRecord::Base.connection.execute("DELETE FROM word_singletons WHERE result_page_id = #{rp.id}")}

      #result_pages.each{|rp| WordPair.where(:result_page_id => rp.id).destroy_all}
      result_pages.each{|rp| ActiveRecord::Base.connection.execute("DELETE FROM word_pairs WHERE result_page_id = #{rp.id}")}

      result_pages.each{|rp| analyse_page(rp, flow_str)}








    end


  end


  def crawl(flow_str)
    logger.info "start crawl for URL #{@domain_home_page}"
    initialize_crawl
    if DomainCrawler.exists?(domain_home_page: @domain_home_page) or DomainCrawler.exists?(domain_home_page: @domain_home_page[0..-2]) or DomainCrawler.exists?(domain_home_page: @domain_home_page+'/')
      current_version = DomainCrawler.where(domain_home_page: domain_home_page).order("version DESC").first +1
    else
      current_version = 1
    end

    #@domain_crawler.user_id = current_user_id
    #@domain_crawler.version = current_version
    #@domain_crawler.domain_name = domain

    ProcessPage(domain_home_page, @current_level, @parent_id, flow_str)
    #   logger.info "BB @parent_id = #{@parent_id}, level = #{current_level}"
    count = 1
    @current_pages.each do |page, level|
      #   logger.info "#{count}: Page = #{page}, Level = #{level}"
      count = count+1
    end

    logger.info "end of crawl"
    #return @current_pages
    page= CrawlerPage.find_by_id(@first_page_id)
    if page != nil
      first_page_id  =  page.root.id
    else
      first_page_id = 0
    end
    return first_page_id

  end
end



