require 'optparse'
require 'rexml/document'
require 'chainsaw/parse'

module Chainsaw

  class CLI

    def CLI.execute


      options = { :expr => ".", 
                    :operate_on => :all, 
                    :abnormal_exit => 1,
                    :normal_exit => 0,
                    :quiet => false,
                    :print => :node }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: chainsaw file [options]"
        
        opts.on('--expr EXPRESSION', 'Finds nodes that match EXPRESSION.') do |expr|
          options[:expr] = expr
        end

        opts.on('--prune', 'Prune the matched nodes from the output') do
          options[:prune] = true
        end

        opts.on('--print', 'Print the matched nodes') do
          options[:print] = :node
          options[:quiet] = false
        end

        opts.on('--matched', 'Exit with the number of matched elements.  If this option is turned on, an abnormal exit will be -1.') do
            options[:matched] = true
            options[:abnormal_exit] = -1
        end
        
        opts.on('--quiet', 'Turns off all output.  Useful for testing to see if an expression matches any nodes') do
            options[:quiet] = true
            options[:print] = nil
        end
        
        opts.on('--delimeter STRING', 'Delimeter to print between each result node') do |delimeter|
            options[:delimeter] = delimeter
        end

        # opts.on('--text', 'Returns the text of the node(s) returned by -expr.  This can be combined with -first, -last, and -all') do
        #   options[:print] = :text
        # end

        opts.on('--pretty', 'Pretty print') do 
          options[:pretty_print] = true
        end

        opts.on('--first', 'Matches only the first node in the nodeset returned by -expr') do 
          options[:operate_on] = :first
        end

        opts.on('--last', 'Matches only the last node in the nodeset returned by -expr') do
          options[:operate_on] = :last
        end

        opts.on('--all', 'Matches all of the nodes in the nodeset returned by -expr') do
          options[:operate_on] = :all
        end

        opts.on('--insert XML', 'Inserts XML before the node(s) returned by -expr') do |xml|
          xml = File.new(xml) if xml[0] == "@"
          fragment = REXML::Document.new(xml)
          options[:insert] = fragment
        end

        opts.on('--append XML', 'Appends XML as a child of the node(s) returned by -expr') do |xml|
          xml = File.new(xml) if xml[0] == "@"
          fragment = REXML::Document.new(xml)
          options[:append] = fragment
        end

        opts.on('--replace XML', 'Replaces the node(s) returned by -expr with XML') do |xml|
          xml = File.new(xml) if xml[0] == "@"
          fragment = REXML::Document.new(xml)
          options[:replace] = fragment
        end
        
        opts.on('--help', 'Displays this message') do
            puts opts.help
            exit options[:abnormal_exit]
        end

      end.parse!

      options[:filename] = ARGV.shift
      
      if (options[:pretty_print])
        formatter = REXML::Formatters::Pretty.new
      else
        formatter = REXML::Formatters::Default.new
      end

      
      if not options[:filename].nil?
        begin
          file = File.new(options[:filename])
        rescue
          puts "Couldn't open " + options[:filename]
          exit options[:abnormal_exit]
        end
      else
        file = STDIN
      end      

      document = REXML::Document.new(file)
      matches = REXML::XPath.match(document, options[:expr])

      matches.each_with_index do |node, i|
        
        if ((options[:operate_on] == :first and i == 0) or
            (options[:operate_on] == :last and i == matches.count - 1) or
            (options[:operate_on] == :all))
          
          if (options[:print])
            # if (options[:print] == :text)
            #   formatter.write_text(node, STDOUT)
            # else
              formatter.write node, STDOUT
              puts options[:delimeter]
            # end
          end

          if (options[:prune])
            node.remove
          end

          if (options[:insert])
            fragment = options[:insert].deep_clone
            node.parent.insert_before node, fragment
          end

          if (options[:append])
            fragment = options[:append].deep_clone
            node << fragment
          end

          if (options[:replace])
            fragment = options[:replace].deep_clone
            node.parent.replace_child node, fragment
          end

        end
      end

      if (not options[:print] and not options[:quiet]) then
        formatter.write document, STDOUT
      end

      if options[:matched] then
        exit matches.count
      elsif options[:quiet] then
        if matches.count == 0 then
          exit options[:abnormal_exit]
        else
          exit options[:normal_exit]
        end
      else
        exit options[:normal_exit]
      end
      
    end
    
  end

end
