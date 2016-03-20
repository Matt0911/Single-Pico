ruleset track_trips2 {
  meta {
    name "Track Trips 2"
    description <<
Part 2 Track Trips
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides process_trip
  }

  rule process_trip {
    select when car new_trip
    pre{
      mileage = event:attr("mileage");
    }
    {
      send_directive("trip") with
        trip_length = "#{mileage}";
    }
  }
}