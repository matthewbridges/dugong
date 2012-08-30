<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="RST_I" />
        <signal name="XLXN_10" />
        <signal name="XLXN_14" />
        <signal name="XLXN_15" />
        <signal name="XLXN_16(30:0)" />
        <signal name="GPIO(7:0)" />
        <signal name="XLXN_21(16:0)" />
        <signal name="XLXN_22" />
        <signal name="XLXN_26" />
        <signal name="sys_clk_p" />
        <signal name="sys_clk_n" />
        <signal name="XLXN_8" />
        <signal name="XLXN_30" />
        <signal name="XLXN_31" />
        <port polarity="Input" name="RST_I" />
        <port polarity="Output" name="GPIO(7:0)" />
        <port polarity="Input" name="sys_clk_p" />
        <port polarity="Input" name="sys_clk_n" />
        <blockdef name="dugong">
            <timestamp>2012-8-30T10:29:44</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
        </blockdef>
        <blockdef name="gpio_controller_ip">
            <timestamp>2012-8-30T10:31:8</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
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
        <blockdef name="clk_generator">
            <timestamp>2012-8-30T10:33:51</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <block symbolname="dugong" name="XLXI_1">
            <blockpin signalname="XLXN_31" name="CLK_I" />
            <blockpin signalname="XLXN_15" name="RST_I" />
            <blockpin signalname="XLXN_21(16:0)" name="WB_I(16:0)" />
            <blockpin signalname="XLXN_16(30:0)" name="WB_O(30:0)" />
        </block>
        <block symbolname="gpio_controller_ip" name="XLXI_2">
            <blockpin signalname="XLXN_31" name="CLK_I" />
            <blockpin signalname="XLXN_15" name="RST_I" />
            <blockpin signalname="XLXN_16(30:0)" name="WB_I(30:0)" />
            <blockpin signalname="XLXN_21(16:0)" name="WB_O(16:0)" />
            <blockpin signalname="GPIO(7:0)" name="GPIO(7:0)" />
        </block>
        <block symbolname="or2" name="XLXI_6">
            <blockpin signalname="XLXN_10" name="I0" />
            <blockpin signalname="RST_I" name="I1" />
            <blockpin signalname="XLXN_15" name="O" />
        </block>
        <block symbolname="clk_generator" name="XLXI_8">
            <blockpin signalname="sys_clk_p" name="CLK_IN1_P" />
            <blockpin signalname="sys_clk_n" name="CLK_IN1_N" />
            <blockpin signalname="XLXN_8" name="RESET" />
            <blockpin signalname="XLXN_31" name="CLK_OUT1" />
            <blockpin signalname="XLXN_30" name="CLK_VALID" />
        </block>
        <block symbolname="gnd" name="XLXI_4">
            <blockpin signalname="XLXN_8" name="G" />
        </block>
        <block symbolname="inv" name="XLXI_12">
            <blockpin signalname="XLXN_30" name="I" />
            <blockpin signalname="XLXN_10" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="RST_I">
            <wire x2="1024" y1="1456" y2="1456" x1="336" />
            <wire x2="1024" y1="1456" y2="1616" x1="1024" />
            <wire x2="1040" y1="1616" y2="1616" x1="1024" />
        </branch>
        <instance x="1040" y="1744" name="XLXI_6" orien="R0" />
        <branch name="XLXN_10">
            <wire x2="1040" y1="1712" y2="1712" x1="992" />
            <wire x2="1040" y1="1680" y2="1712" x1="1040" />
        </branch>
        <instance x="1456" y="1744" name="XLXI_1" orien="R0">
        </instance>
        <branch name="XLXN_15">
            <wire x2="1376" y1="1648" y2="1648" x1="1296" />
            <wire x2="1456" y1="1648" y2="1648" x1="1376" />
            <wire x2="1936" y1="1520" y2="1520" x1="1376" />
            <wire x2="1376" y1="1520" y2="1648" x1="1376" />
        </branch>
        <instance x="1936" y="1616" name="XLXI_2" orien="R0">
        </instance>
        <branch name="XLXN_16(30:0)">
            <wire x2="1936" y1="1584" y2="1584" x1="1840" />
        </branch>
        <branch name="GPIO(7:0)">
            <wire x2="2608" y1="1584" y2="1584" x1="2320" />
        </branch>
        <iomarker fontsize="28" x="2608" y="1584" name="GPIO(7:0)" orien="R0" />
        <branch name="XLXN_21(16:0)">
            <wire x2="1456" y1="1712" y2="1712" x1="1408" />
            <wire x2="1408" y1="1712" y2="1776" x1="1408" />
            <wire x2="2384" y1="1776" y2="1776" x1="1408" />
            <wire x2="2384" y1="1456" y2="1456" x1="2320" />
            <wire x2="2384" y1="1456" y2="1776" x1="2384" />
        </branch>
        <branch name="sys_clk_p">
            <wire x2="368" y1="1584" y2="1584" x1="336" />
        </branch>
        <branch name="sys_clk_n">
            <wire x2="368" y1="1648" y2="1648" x1="336" />
        </branch>
        <branch name="XLXN_8">
            <wire x2="240" y1="1712" y2="1744" x1="240" />
            <wire x2="368" y1="1712" y2="1712" x1="240" />
        </branch>
        <instance x="368" y="1744" name="XLXI_8" orien="R0">
        </instance>
        <instance x="176" y="1872" name="XLXI_4" orien="R0" />
        <iomarker fontsize="28" x="336" y="1584" name="sys_clk_p" orien="R180" />
        <iomarker fontsize="28" x="336" y="1648" name="sys_clk_n" orien="R180" />
        <instance x="768" y="1744" name="XLXI_12" orien="R0" />
        <branch name="XLXN_30">
            <wire x2="768" y1="1712" y2="1712" x1="752" />
        </branch>
        <branch name="XLXN_31">
            <wire x2="1312" y1="1584" y2="1584" x1="752" />
            <wire x2="1456" y1="1584" y2="1584" x1="1312" />
            <wire x2="1936" y1="1456" y2="1456" x1="1312" />
            <wire x2="1312" y1="1456" y2="1584" x1="1312" />
        </branch>
        <iomarker fontsize="28" x="336" y="1456" name="RST_I" orien="R180" />
    </sheet>
</drawing>