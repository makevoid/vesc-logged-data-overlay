
  # ----
  # calc:

  # configs:
  wheel_size  = 97.0
  motor_teeth = 15.0
  wheel_teeth = 36.0
  batt_cells  = 8 # S
  # batt_cell_volts = 3.7 # lipo
  batt_cell_volts = 3.6 # li-ion
  batt_volts  = batt_cell_volts * 8
  # otherwise use input voltage1

  gear_ratio = motor_teeth / wheel_teeth
  erpm = d["rpm"]


    erpm = batt_volts * motor_kv * 7

  motor_rpm =
  speed_mph = motor_rpm * wheel_size * Math::PI * CALC_R * gear_ratio
  speed = speed_mph
  rows << ["speed:         ", "#{speed.round 2} mph"]
  # rows << ["speed:          ", "#{speed} km/h"]
