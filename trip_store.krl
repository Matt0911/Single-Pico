ruleset track_store {
  meta {
    name "Trip Store"
    description <<
Part 3 Store Trips
>>
    author "Matt Manhardt"
    logging on
    sharing on
    //provides trips
    //provides long_trips
    //provides short_trips
  }

  global {
    trips = function() {
      trips = ent:trips;
      times = trips.keys();
      output = times.map(function(x) {x + ", " + trips{[x]} + " miles"});
      output
    };

    long_trips = function() {
      longtrips = ent:longTrips;
      times = longtrips.keys();
      output = times.map(function(x) {x + ", " + longtrips{[x]} + " miles"});
      output
    };

    short_trips = function() {
      trips = ent:trips;
      longtrips = ent:longTrips;
      longtimes = longtrips.keys();
      trips = trips.delete(longtimes);
      times = trips.keys();
      output = times.map(function(x) {x + ", " + trips{[x]} + " miles"});
      output
    };
  }

  rule colect_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage");
      time = event:attr("time");
    }
    fired {
      log ("LOG Collect trip with: " + mileage);
      
      //set ent:trips init if not ent:trips{["_0"]};
      set ent:trips{[time]} mileage;
      log ("DEBUG ent:trips = " + ent:trips);
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre{
      mileage = event:attr("mileage");
      time = event:attr("time");
    }
    fired {
      log ("LOG Collect Long Trip: " + mileage);
      log ("DEBUG ent:longTrips = ");
      //set ent:longTrips init if not ent:longTrips{["_0"]};
      set ent:longTrips{time} mileage;
    }
  }

  rule clear_trips {
    select when car trip_reset
    always {
      log("LOG Clear all trips");
      clear ent:trips;
      clear ent:longTrips;
    }
  }
}