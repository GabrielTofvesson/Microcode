lcset 16                            # Set LC to 0x10

$NEXT
bls @END; incpc; declc; add pc      # Increment PC, decrement LC, add PC (pre-increment) to AR and then branch to END if LC is (pre-decrement) 0
bra @NEXT

$END
halt                                # Stop execution
