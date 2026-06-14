import 'package:flutter/material.dart';
import 'package:date_time_format/date_time_format.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({super.key,this.getDate,this.getTime});

  final void Function(String date)? getDate;
  final void Function(String time)? getTime;
  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  final TextEditingController _dateController=TextEditingController();
  final TextEditingController _timeController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Date",style: TextStyle(color: Colors.black,fontSize: 20),),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: "Pick The Date",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black,width:1.5),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.date_range_outlined,color:Color(0xFF3E5974)),
                ),
                onTap: ()async{
                  DateTime? datePicked= await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if(datePicked!=null){
                    setState(() {
                      _dateController.text=datePicked.format('M j');
                    });
                    widget.getDate!(_dateController.text);
                  }
                },
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                validator: (value){
                  if(value==null || value.isEmpty)
                    {
                      return 'Please pick a date';
                    }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Time",style: TextStyle(color: Colors.black,fontSize: 20),),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  hintText: "Pick The Time",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black,width:1.5),
                  ),
                  fillColor:Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.timer_outlined,color: Color(0xFF3E5974)),
                ),
                onTap: ()async{
                  TimeOfDay? timePicked= await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if(timePicked!=null){
                    setState(() {
                      _timeController.text=timePicked.format(context);
                    });
                    widget.getTime!(_timeController.text);
                  }
                },
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                validator: (value){
                  if(value==null || value.isEmpty)
                  {
                    return 'Please pick a time';
                  }
                  return null;
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
