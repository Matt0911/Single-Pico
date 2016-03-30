ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    description <<
Fleet manager Part 1
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides vehicles
    provides children
    use module  b507199x5 alias wranglerOS
  }

  global {
    long_trip = 100;

    vehicles = function() {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"};
      subed = subscriptions{"subscribed"};
      sub = subed[0];
      name = sub{"subscription_name"};
      name
    };

    children = function() {
      results = wranglerOS:name();
      name = results{"picoName"};
      name
    }

  }

  rule create_vehicle {
    select when car new_vehicle
    pre{
      vehicle_name = event:attr("name");
      attr = {}
                              .put(["Prototype_rids"],"b507742x3.prod") // ; separated rulesets the child needs installed at creation
                              .put(["name"],vehicle_name) // name for child_name
                              .put(["parent_eci"],parent_eci) // eci for child to subscribe
                              ;
    }
    {
      noop();
    }
    always{
      raise wrangler event "child_creation"
      attributes attr.klog("attributes: ");
      log("create child for " + child);
    }
  }

  rule autoAccept {
    select when wrangler inbound_pending_subscription_added 
    pre{
      attributes = event:attrs().klog("subcription :");
    }
    {
      noop();
    }
    always{
      raise wrangler event 'pending_subscription_approval'
          attributes attributes;        
          log("auto accepted subcription.");
    }
  }
  
}