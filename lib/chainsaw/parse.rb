require 'chainsaw/eval'

module Chainsaw

  class Node
    
    # Evaluates the node in the context of an Chainsaw.EvaluationContext
    def evalute(context)
    end
      
  end
  
  class XPathExpression < Node
  
    # Which nodes to operate on :first, :last, :all
    @which = :all
    
    # XPath expression to evaluate
    @expression = nil
    
    def evaluate(context)
      matches = REXML::XPath.match(context.document, @expression)
      count = matches.count
      if (@which == :first and matches.count > 0)
        matches = [matches[0]]
      elsif (@which == :last and matches.count > 0) 
        matches = [matches[matches.count - 1]]
      end
      
      context.matches = matches
    end
    
  end
  
  class Action < Node
  
  end
  
  
  class Prune < Action
    
    def evaluate(context)
      context.matches.each do |node|
        node.remove
      end
    end
    
  end
  
  class Print < Action
  
    # Formatter to use when printing the output
    @formatter = nil
    
    # Delimiter to use between each match.
    @delimeter = "\n"
  
    def evaluate(context)
      context.matches.each do |node|
        @formatter.write node, STDOUT
        puts @delimiter
      end
    end
  
  end
  
  class PrintMatched < Action
    
    def evaluate(context)
      exit(context.matches.count)
    end
    
  end
  
  class QuietAction < Action
    def evaluate(context)
      if (context.matches.count == 0) then
        exit(1)
      else
        exit(0)
      end
    end
  end
  
  class DOMAction < Action
  
    # XML to perform the operation on.
    @xml = nil
  
  end
  
  class Insert < DOMAction
  
    def evaluate(context)
      context.matches.each do |node|
        fragment = @xml.deep_clone
        node.parent.insert_before node, fragment
      end
    end

  end
  
  class Append < DOMAction

    def evaluate(context)
      context.matches.each do |node|
        fragment = @xml.deep_clone
        node << fragment
      end
    end

  end
  
  class Replace < DOMAction

    def evaluate(context)
      context.matches.each do |node|
        fragment = @xml.deep_clone
        node.parent.replace_child node, fragment
      end
    end
      
  end

  # Represents a command to execute.  The @expression node holds the expression to
  # evaluate.  For all of the nodes that match the expression, the @action will BEGIN
  # performed
  class Command < Action
  
    @expression = nil
    @action = nil
  
  end
  
end