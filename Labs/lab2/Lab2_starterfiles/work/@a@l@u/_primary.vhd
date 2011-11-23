library verilog;
use verilog.vl_types.all;
entity ALU is
    port(
        ALUResult       : out    vl_logic_vector(31 downto 0);
        ALUZero         : out    vl_logic;
        ALUNeg          : out    vl_logic;
        ALUOp           : in     vl_logic_vector(3 downto 0);
        ALUOpX          : in     vl_logic_vector(31 downto 0);
        ALUOpY          : in     vl_logic_vector(31 downto 0)
    );
end ALU;
