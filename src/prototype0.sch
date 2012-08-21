<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="XLXN_1" />
        <signal name="XLXN_2" />
        <signal name="XLXN_3(15:0)" />
        <signal name="XLXN_5" />
        <signal name="XLXN_6(15:0)" />
        <signal name="CLK_I" />
        <signal name="RST_I" />
        <signal name="XLXN_7(11:0)" />
        <signal name="XLXN_7(3:0)" />
        <signal name="sys_clk_n" />
        <signal name="sys_clk_p" />
        <signal name="XLXN_8" />
        <signal name="XLXN_10" />
        <signal name="XLXN_11" />
        <signal name="XLXN_13" />
        <signal name="GPIO(7:0)" />
        <signal name="Debug(15:0)" />
        <port polarity="Input" name="RST_I" />
        <port polarity="Input" name="sys_clk_n" />
        <port polarity="Input" name="sys_clk_p" />
        <port polarity="Output" name="GPIO(7:0)" />
        <port polarity="Output" name="Debug(15:0)" />
        <blockdef name="dugong">
            <timestamp>2012-8-10T15:43:41</timestamp>
            <rect width="288" x="64" y="-320" height="320" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-208" y2="-208" x1="64" />
            <line x2="0" y1="-128" y2="-128" x1="64" />
            <rect width="64" x="0" y="-60" height="24" />
            <line x2="0" y1="-48" y2="-48" x1="64" />
            <line x2="416" y1="-288" y2="-288" x1="352" />
            <line x2="416" y1="-224" y2="-224" x1="352" />
            <line x2="416" y1="-160" y2="-160" x1="352" />
            <rect width="64" x="352" y="-108" height="24" />
            <line x2="416" y1="-96" y2="-96" x1="352" />
            <rect width="64" x="352" y="-44" height="24" />
            <line x2="416" y1="-32" y2="-32" x1="352" />
        </blockdef>
        <blockdef name="gpio_controller_ip">
            <timestamp>2012-8-10T15:48:18</timestamp>
            <rect width="256" x="64" y="-384" height="384" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-352" y2="-352" x1="320" />
            <rect width="64" x="320" y="-268" height="24" />
            <line x2="384" y1="-256" y2="-256" x1="320" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <rect width="64" x="320" y="-76" height="24" />
            <line x2="384" y1="-64" y2="-64" x1="320" />
        </blockdef>
        <blockdef name="clk_generator">
            <timestamp>2012-8-15T15:10:52</timestamp>
            <rect width="544" x="32" y="32" height="1056" />
            <line x2="32" y1="112" y2="112" x1="0" />
            <line x2="32" y1="144" y2="144" x1="0" />
            <line x2="32" y1="432" y2="432" x1="0" />
            <line x2="576" y1="80" y2="80" x1="608" />
            <line x2="576" y1="1008" y2="1008" x1="608" />
        </blockdef>
        <blockdef name="gnd">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-96" x1="64" />
            <line x2="52" y1="-48" y2="-48" x1="76" />
            <line x2="60" y1="-32" y2="-32" x1="68" />
            <line x2="40" y1="-64" y2="-64" x1="88" />
            <line x2="64" y1="-64" y2="-80" x1="64" />
            <line x2="64" y1="-128" y2="-96" x1="64" />
        </blockdef>
        <blockdef name="or2">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <arc ex="192" ey="-96" sx="112" sy="-48" r="88" cx="116" cy="-136" />
            <arc ex="48" ey="-144" sx="48" sy="-48" r="56" cx="16" cy="-96" />
            <line x2="48" y1="-144" y2="-144" x1="112" />
            <arc ex="112" ey="-144" sx="192" sy="-96" r="88" cx="116" cy="-56" />
            <line x2="48" y1="-48" y2="-48" x1="112" />
        </blockdef>
        <blockdef name="inv">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
        </blockdef>
        <block symbolname="clk_generator" name="XLXI_3">
            <blockpin signalname="sys_clk_p" name="clk_in1_p" />
            <blockpin signalname="sys_clk_n" name="clk_in1_n" />
            <blockpin signalname="XLXN_8" name="reset" />
            <blockpin signalname="CLK_I" name="clk_out1" />
            <blockpin signalname="XLXN_11" name="clk_valid" />
        </block>
        <block symbolname="dugong" name="XLXI_1">
            <blockpin signalname="CLK_I" name="CLK_I" />
            <blockpin signalname="XLXN_13" name="RST_I" />
            <blockpin signalname="XLXN_5" name="ACK_I" />
            <blockpin signalname="XLXN_6(15:0)" name="DAT_I(15:0)" />
            <blockpin signalname="XLXN_1" name="WE_O" />
            <blockpin signalname="XLXN_2" name="STB_O" />
            <blockpin name="CYC_O" />
            <blockpin signalname="XLXN_3(15:0)" name="DAT_O(15:0)" />
            <blockpin signalname="XLXN_7(11:0)" name="ADR_O(11:0)" />
        </block>
        <block symbolname="gpio_controller_ip" name="XLXI_2">
            <blockpin signalname="CLK_I" name="CLK_I" />
            <blockpin signalname="XLXN_13" name="RST_I" />
            <blockpin signalname="XLXN_1" name="WE_I" />
            <blockpin signalname="XLXN_2" name="STB_I" />
            <blockpin signalname="XLXN_3(15:0)" name="DAT_I(15:0)" />
            <blockpin signalname="XLXN_7(3:0)" name="ADR_I(3:0)" />
            <blockpin signalname="XLXN_5" name="ACK_O" />
            <blockpin signalname="XLXN_6(15:0)" name="DAT_O(15:0)" />
            <blockpin signalname="GPIO(7:0)" name="GPIO(7:0)" />
            <blockpin signalname="Debug(15:0)" name="Debug(15:0)" />
        </block>
        <block symbolname="gnd" name="XLXI_4">
            <blockpin signalname="XLXN_8" name="G" />
        </block>
        <block symbolname="or2" name="XLXI_6">
            <blockpin signalname="XLXN_10" name="I0" />
            <blockpin signalname="RST_I" name="I1" />
            <blockpin signalname="XLXN_13" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_7">
            <blockpin signalname="XLXN_11" name="I" />
            <blockpin signalname="XLXN_10" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1424" y="1856" name="XLXI_1" orien="R0">
        </instance>
        <instance x="2096" y="1792" name="XLXI_2" orien="R0">
        </instance>
        <branch name="XLXN_1">
            <wire x2="2096" y1="1568" y2="1568" x1="1840" />
        </branch>
        <branch name="XLXN_2">
            <wire x2="2096" y1="1632" y2="1632" x1="1840" />
        </branch>
        <branch name="XLXN_3(15:0)">
            <wire x2="1968" y1="1760" y2="1760" x1="1840" />
            <wire x2="1968" y1="1696" y2="1760" x1="1968" />
            <wire x2="2096" y1="1696" y2="1696" x1="1968" />
        </branch>
        <branch name="XLXN_5">
            <wire x2="1376" y1="1344" y2="1728" x1="1376" />
            <wire x2="1424" y1="1728" y2="1728" x1="1376" />
            <wire x2="2544" y1="1344" y2="1344" x1="1376" />
            <wire x2="2544" y1="1344" y2="1440" x1="2544" />
            <wire x2="2544" y1="1440" y2="1440" x1="2480" />
        </branch>
        <branch name="XLXN_6(15:0)">
            <wire x2="1424" y1="1808" y2="1808" x1="1360" />
            <wire x2="1360" y1="1808" y2="1936" x1="1360" />
            <wire x2="2560" y1="1936" y2="1936" x1="1360" />
            <wire x2="2560" y1="1536" y2="1536" x1="2480" />
            <wire x2="2560" y1="1536" y2="1936" x1="2560" />
        </branch>
        <branch name="XLXN_7(11:0)">
            <wire x2="1984" y1="1824" y2="1824" x1="1840" />
            <wire x2="1984" y1="1600" y2="1760" x1="1984" />
            <wire x2="1984" y1="1760" y2="1824" x1="1984" />
        </branch>
        <bustap x2="2080" y1="1760" y2="1760" x1="1984" />
        <branch name="XLXN_7(3:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="2088" y="1760" type="branch" />
            <wire x2="2096" y1="1760" y2="1760" x1="2080" />
        </branch>
        <instance x="368" y="1488" name="XLXI_3" orien="R0">
        </instance>
        <branch name="sys_clk_n">
            <wire x2="368" y1="1632" y2="1632" x1="336" />
        </branch>
        <iomarker fontsize="28" x="336" y="1632" name="sys_clk_n" orien="R180" />
        <branch name="sys_clk_p">
            <wire x2="368" y1="1600" y2="1600" x1="336" />
        </branch>
        <iomarker fontsize="28" x="336" y="1600" name="sys_clk_p" orien="R180" />
        <branch name="CLK_I">
            <wire x2="1408" y1="1568" y2="1568" x1="976" />
            <wire x2="1424" y1="1568" y2="1568" x1="1408" />
            <wire x2="2096" y1="1440" y2="1440" x1="1408" />
            <wire x2="1408" y1="1440" y2="1568" x1="1408" />
        </branch>
        <instance x="192" y="2080" name="XLXI_4" orien="R0" />
        <branch name="XLXN_8">
            <wire x2="368" y1="1920" y2="1920" x1="256" />
            <wire x2="256" y1="1920" y2="1952" x1="256" />
        </branch>
        <iomarker fontsize="28" x="848" y="1344" name="RST_I" orien="R180" />
        <branch name="RST_I">
            <wire x2="1008" y1="1344" y2="1344" x1="848" />
            <wire x2="1008" y1="1344" y2="1616" x1="1008" />
            <wire x2="1040" y1="1616" y2="1616" x1="1008" />
        </branch>
        <instance x="1040" y="1744" name="XLXI_6" orien="R0" />
        <branch name="XLXN_10">
            <wire x2="1040" y1="1680" y2="1712" x1="1040" />
        </branch>
        <instance x="1072" y="1936" name="XLXI_7" orien="R270" />
        <branch name="XLXN_11">
            <wire x2="1040" y1="2496" y2="2496" x1="976" />
            <wire x2="1040" y1="1936" y2="2496" x1="1040" />
        </branch>
        <branch name="XLXN_13">
            <wire x2="1328" y1="1648" y2="1648" x1="1296" />
            <wire x2="1424" y1="1648" y2="1648" x1="1328" />
            <wire x2="2096" y1="1504" y2="1504" x1="1328" />
            <wire x2="1328" y1="1504" y2="1648" x1="1328" />
        </branch>
        <branch name="GPIO(7:0)">
            <wire x2="2496" y1="1632" y2="1632" x1="2480" />
            <wire x2="2800" y1="1632" y2="1632" x1="2496" />
        </branch>
        <branch name="Debug(15:0)">
            <wire x2="2496" y1="1728" y2="1728" x1="2480" />
            <wire x2="2800" y1="1728" y2="1728" x1="2496" />
        </branch>
        <iomarker fontsize="28" x="2800" y="1728" name="Debug(15:0)" orien="R0" />
        <iomarker fontsize="28" x="2800" y="1632" name="GPIO(7:0)" orien="R0" />
    </sheet>
</drawing>