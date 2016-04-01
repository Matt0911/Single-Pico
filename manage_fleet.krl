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
      i = ent:numChildren;
      i = i - 1;
      sub = subscribed[i];
      subKeys = sub.keys();
      info = sub{[subKeys[0]]};
      info
    };

    children = function() {
      results = wranglerOS:children();
      childrenArray = results{["children"]};
      i = ent:numChildren;
      i = i - 1;
      childinfo = childrenArray[i];
      childeci = childinfo[0];
      childeci
    }

  }

  rule create_vehicle {
    select when car new_vehicle
    pre{
      vehicle_name = event:attr("name");
      results = wranglerOS:children();
      childrenArray = results{["children"]};
      i = ent:numChildren;
      newi = i + 1;
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
      //log("create child for " + child);
      
      log ("ENT:numCHILDREN: " + i);
      
      // SET MAP 
      set ent:children{vehicle_name} i;
      set ent:numChildren newi;
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      deleteECI = event:attr("eci");
      i = ent:numChildren;
      i = i -1;
    }
    always {
      log("PICO TO BE DELETED: " + picoName);
      set ent:numChildren i;
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