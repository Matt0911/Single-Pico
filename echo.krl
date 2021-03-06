ruleset echo {
  meta {
    name "Echo"
    description <<
Part 1 Echo
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides hello
    provides message
  }
  global {
    hello = function(obj) {
      msg = "Hello " + obj
      msg
    };
 
  }
  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World";
  }

  rule message {
    select when echo message
    pre{
      input = event:attr("input");
    }
    {
      send_directive("say") with
        something = "#{input}";
    }
  }
}
