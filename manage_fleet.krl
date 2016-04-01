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
    provides getSubName
    provides getChildECI
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
      subname = info{["back_channel"]};
      subname
    };

    children = function() {
      results = wranglerOS:children();
      childrenArray = results{["children"]};
      i = ent:numChildren;
      i = i - 1;
      childinfo = childrenArray[i];
      childeci = childinfo[0];
      ent:children
    }

    getSubName = function(name) {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"};
      subscribed = subscriptions{"subscribed"};
      i = ent:children{name};
      sub = subscribed[i];
      subKeys = sub.keys();
      info = sub{[subKeys[0]]};
      subname = info{["back_channel"]};
      subname
    };

    getChildECI = function(name) {
      results = wranglerOS:children();
      childrenArray = results{["children"]};
      i = ent:children{name};
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
      picoName = event:attr("name");
      subname = getSubName(picoName);
      eci = getChildECI(name);

      childmap = ent:children;
      newmap = childmap.delete(name)
      

    }
    always {
      log("PICO TO BE DELETED: " + picoName);
      set ent:numChildren i;

      log("PICO DELETED, NEW numCHILDREN: " + ent:numChildren);
      raise car event 'delete_vehicle'
        with eci = deleteECI;
    }

  }

    rule remove_car {
    select when car delete_vehicle
    pre {
      eci = event:attr("eci");
      results = wranglerOS:name();
      picoName = results{"picoName"};

      subs = wranglerOS:subscriptions();
      //log ("subscriptions: " + subs);
      subscriptions = subs{"subscriptions"};
      subscribed = subscriptions{"subscribed"};
      sub = subscribed[0];
      subKeys = sub.keys();
      info = sub{[subKeys[0]]};
      subname = info{["back_channel"]};
      //log ("attr: " + name + ", pico: " + picoName + ", sub: " + subname);
    }
    fired {
      log("SUBNAME: " + subname);
      raise wrangler event 'subscription_cancellation'
        with channel_name = subname
        if (name == picoName);
      log("DELETION ATTRIBUTES attr: " + eci + ", pico: " + picoName + ", sub: " + subname);
      raise wrangler event 'child_deletion'
        with deletionTarget = eci;
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