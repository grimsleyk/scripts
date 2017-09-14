

# constants
tmpCreateDir=
createDir="create"


# set up tem files
#cd autobids/build/
echo "setting up environment..."
rm -rf "/tmp/create"
#mv db/dynamo/create/*tmpCreateDirtmp/create
cp -rf "create" "/tmp/create"
rm -rf "create/"*
#dynamoComplete="completed dynamo table deletion"

# put contents of create into array
echo "creating array..."
createFiles=($(ls "/tmp/create"))
# loop through contents
for file in "${createFiles[@]}"
do
   #echo $file
   cp -rf "/tmp/create/""$file" "create"
   echo "creating: " "$file"
   node db create --env=qa
   rm -rf "create/*"
done

# clean up
echo cleaning up...
cp -rf "/tmp/create/" "create"
rm -rf "/tmp/create"
