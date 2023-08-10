#	8-bit pseudo-random number generator(LSFR)

#	@ Polynomial
#	P(x) = x^8 + x^6 + x^5 + x^4 + 1
#   taps: 8 6 5 4 1
#	
#	@ Seed
#   second lastname: Fallas
#	=> F : 0x46 / b01000110

#	Memory position -> 0x100
#   
#   @ Byte positions
#   (MSB)          (LSB)
#   -> [1|2|3|4|5|6|7|8] ->
# 
#   Daniel García Fallas IIS 2023
#------------------------------------------------

start:
    li a1,0x46          # [a1] <- 0x46 : lsfr_value 
    li a2,0x100         # [a2] <- 0x100 : mem_pos
    sw a1,0(a2)         # 0x56 -> M[0x100] 
    li a3,0x0           # [a3] <- 0x0 : counter
    li a4,0x64          # [a4] <- 0x64 : stop_count(100)


lsfr:
    
   
    srli s0,a1,0x2      # [s1] <- [lsfr_value] >> 2 (pos 6)
    srli s1,a1,0x3      # [s2] <- [lsfr_value] >> 3 (pos 5)
    srli s2,a1,0x4      # [s3] <- [lsfr_value] >> 4 (pos 4)
    
    # First xor between b8 and b6
    
    xor t0,s0,a1        # [t0] <- [a1] ^ [s0] : [b8] xor [b6]
    
    # Second xor between result ( b8 xor b6) and b5
    
    xor t1,s1,t0        # [t1] <- [s1] ^ [s0] : [result(b8 xor b6)] xor [b5]
    
    # Third xor between result (b5 and result b8 xor b6) and b4
    
    xor t2,s2,t1        # [t2] <- [s1] ^ [t1] : [result( result(b8 xor b6) xor [b5] )] xor [b4]
    
    andi t3,t2,0x1      # [t3] <- [t0] & 00000001 : just the xor resulting bit
    
    slli t3,t3,0x7      # [t3] <- [t4] << 7 : put in MSB position
    
    srli t4,a1,0x1      # [t4] <- [lsfr_value] >> 1 : descart LSB
    
    add a1,t4,t3        # [a1] <- [t4] + r_bit
    
check:
    addi a3,a3,0x1      # counter = counter + 1
    addi a2,a2,0x4      # mem_pos = mem_pos + 4
    sw a1,0(a2)         # [lsfr_value] -> M[mem_pos]
    blt a3,a4,lsfr      # counter < stop_count? -> lsfr
    j end               # else: go to end


end:
    nop                  # end algorithm