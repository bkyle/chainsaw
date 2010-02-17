require 'optparse'
require 'rexml/document'

module XMLP

  class CLI

    def CLI.execute

      options = { :expr => ".", :operate_on => :all }

      options[:filename] = ARGV.shift

      OptionParser.new do |opts|
        opts.banner = "Usage: xmlp [options]"
        
        opts.on('--expr EXPRESSION', 'Finds nodes that match EXPRESSION.') do |expr|
          options[:expr] = expr
        end

        opts.on('--prune', 'Prune the matched nodes from the output') do
          options[:prune] = true
        end

        opts.on('--print', 'Print the matched nodes') do
          options[:print] = :node
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

      end.parse!

      if (options[:pretty_print])
        formatter = REXML::Formatters::Pretty.new
      else
        formatter = REXML::Formatters::Default.new
      end

      file = File.new(options[:filename])
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

      if (not options[:print])
        formatter.write document, STDOUT
      end

    end
    
  end

end
