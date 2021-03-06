ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    description <<
Fleet manager Part 1
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides fleetReport
    provides children
    provides getSubName
    provides getChildECI
    use module b507199x5 alias wranglerOS
  }

  global {
    long_trip = 100;

    fleetReport = function() {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"};
      subscribed = subscriptions{"subscribed"};
      sub = subscribed[i];
      subKeys = sub.keys();

      //r = function(subKeys, h, sub) {
        //top = a.head();
        info = sub{[subKeys[0]]};
        subname = info{["event_eci"]};
        output = http:get("https://cs.kobj.net/sky/cloud/b507742x4.prod/trips", 
                            {"_eci" : subname});
        //newhash = h.put(subname, output{"content"});
        //a.length() > 1 => r(a.tail(), newhash) | newhash;
      //};
      val = output{"content"};
      tripsMap = {};
      tripsMap = tripsMap.put([subname], val);
      tripsMap
    };

    children = function() {
      //results = wranglerOS:children();
      //childrenArray = results{["children"]};
      //i = ent:numChildren;
      //i = i - 1;
      //childinfo = childrenArray[i];
      //childeci = childinfo[0];
      
      ent:children
    };

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
    };
  }

  rule create_vehicle {
    select when car new_vehicle
    pre{
      vehicle_name = event:attr("name");
      results = wranglerOS:children();
      childrenArray = results{["children"]};
      i = ent:count;
      newi = i + 1;
      attr = {}
                              .put(["Prototype_rids"],"b507742x3.prod;b507742x4.prod") // ; separated rulesets the child needs installed at creation
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
      set ent:count newi;
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      childname = event:attr("name");
      subname = getSubName(picoName);
      childeci = getChildECI(name);

      childmap = ent:children;
      newmap = childmap.delete(name);
      
      i = ent:count;
      newi = i - 1;
    }
    always {
      raise wrangler event 'subscription_cancellation'
        with channel_name = subname;
      
      raise wrangler event 'child_deletion'
        with deletionTarget = childeci;

      log("PICO TO BE DELETED: " + childname);
      log("DELETED PICO ECI: " + childeci);
      log("DELETED SUBSCRIPTION BACK CHANNEL: " + subname);
      
      clear ent:count;
      clear ent:children;
      set ent:count newi;
      set ent:children newmap;
      log("DECREMENT COUNTER: " + newi);
      log("PICO DELETED, NEW numCHILDREN: " + ent:count);
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
    always {
      //log("SUBNAME: " + subname);
      //raise wrangler event 'subscription_cancellation'
        //with channel_name = subname
        //if (name == picoName);
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