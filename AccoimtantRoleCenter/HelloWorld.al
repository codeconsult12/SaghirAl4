// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50123 AccountantRoleCenterExt extends "Accountant Role Center"
{
    actions
    {
        modify(Deposit)
        {
            Visible = false;
            ApplicationArea = none;
        }
        modify(Bank)
        { Visible = false; }
        modify(Receivables)
        { Visible = false; }
        modify(Setup)
        { Visible = false; }
        modify(History)
        { Visible = false; }
        modify(Flow)
        { Visible = false; }
        modify(Vendor)
        { Visible = false; }
        modify(Customer)
        { Visible = false; }
        modify("Sales Tax")
        { Visible = false; }
        modify("Cost Accounting")
        { Visible = false; }
        modify("Inventory Valuation")
        { Visible = false; }

        addafter(Payables)
        {
            action("Account Schedule")
            {
                RunObject = report "Account Schedule";
                ApplicationArea = all;
                Visible = true;
            }
            action("Account Schedules Overview")
            {
                ApplicationArea = all;
                RunObject = page "Acc. Schedule Overview";
            }
            action("Analysis View By Dimension")
            {
                ApplicationArea = all;
                RunObject = page "Analysis by Dimensions";
            }
            action("Analysis View Entries")
            {
                ApplicationArea = all;
                RunObject = page "Analysis View Entries";
            }
        }
    }
}