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
      subscribed = subscriptions{"subscribed"};
      sub = subscribed[0];
      subKeys = sub.keys();
      info = sub{[subKeys[0]]};
      info
    };

    children = function() {
      results = wranglerOS:children();
      results
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

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      deleteECI = event:attr("eci");
    }
    always {
      //raise wrangler event 'subscription_cancellation'
        //with channel_name = subname
        //if (name == picoName);
      log("PICO TO BE DELETED: " + picoName);
      raise explicit event 'delete_vehicle' for b507742x3
        with eci = deleteECI;
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