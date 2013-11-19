global SINE_LUT;
lut_size = length(SINE_LUT)
lut_addr_width = (log(2*lut_size)/log(2)) - 1

% open sine_lut_pkg.vhd and make it writable
fid = fopen('sine_lut_pkg.vhd', 'w');

% Write Package Header Information
fprintf(fid, 'library IEEE;\nuse IEEE.STD_LOGIC_1164.ALL;\nuse IEEE.NUMERIC_STD.ALL;\n\n');
fprintf(fid, 'package sine_lut_pkg is\n\n');

fprintf(fid, 'constant LUT_AMPL_WIDTH : natural := %d;\n', AMPL_WIDTH);
fprintf(fid, 'constant LUT_ADDR_WIDTH : natural := %d;\n\n', lut_addr_width);

fprintf(fid, 'type lut_type is array (0 to 2 ** LUT_ADDR_WIDTH - 1) of unsigned(LUT_AMPL_WIDTH - 2 downto 0);\n');
fprintf(fid, 'constant sine : lut_type := (\n');

for i = 1:lut_size
    fprintf(fid, '\t\t%d => to_unsigned(%d, LUT_AMPL_WIDTH - 1),\n', i - 1, SINE_LUT(i));
end

fprintf(fid, '\t\tothers => to_unsigned(0, LUT_AMPL_WIDTH - 1)\n);\n');

% Write Package Footer Information
fprintf(fid, 'end package sine_lut_pkg;\n\npackage body sine_lut_pkg is\nend package body sine_lut_pkg;\n');
fclose(fid);