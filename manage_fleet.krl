ruleset manage_fleer {
  meta {
    name "Manage Fleet"
    description <<
Fleet manager Part 1
>>
    author "Matt Manhardt"
    logging on
    sharing on
    use module  b507199x5 alias wranglerOS
  }

  global {
    long_trip = 100;
  }

  //rule create_vehicle {
    //select when car new_vehicle
    //fired {
      //log ("LOG raise trip_processed event");
      //raise explicit event 'trip_processed'
        //with mileage = event:attr("mileage")
        //and time = time:now();
    //}
  //}

  rule create_vehicle {
    select when car new_vehicle
    pre{
      attributes = {}
                              .put(["Prototype_rids"],"b507742x3.prod") // semicolon separated rulesets the child needs installed at creation
                              .put(["name"],"Test Vehicle") // name for child
                              ;
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_creation")  // wrangler os event.
      with attrs = attributes.klog("attributes: "); // needs a name attribute for child
    }
    always{
      log("create child for " + child);
    }
  }
  
}