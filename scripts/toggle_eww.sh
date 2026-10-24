if [[ "$(eww get toggled)" = "true" ]]
then
	eww update toggled=false
else
	eww update toggled=true
fi

