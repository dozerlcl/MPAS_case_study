undef("pvs")
procedure pvs(x)
local i,varnames
begin
    printVarSummary(x)

    if (isfile(x))then
        varnames = getfilevarnames(x)
        if(.not.any(ismissing(varnames))) then
            do i=0,dimsizes(varnames)-1
                printFileVarSummary (x,varnames(i))
            end do
        end if
    end if

end
