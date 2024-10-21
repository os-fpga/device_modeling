
    assign O_P = I;
    assign O_N = ~I;
    
    `ifndef SYNTHESIS  
        `ifdef TIMED_SIM
          specparam T1 = 0.5;
        
          specify
            (I => O_P) = (T1);
            (I => O_N) = (T1);
          endspecify
      
        `endif // `ifdef TIMED_SIM  
    `endif //  `ifndef SYNTHESIS


    