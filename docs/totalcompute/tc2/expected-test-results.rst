.. _docs/totalcompute/tc2/expected-test-results:

Expected test results
=====================

.. contents::

.. _docs/totalcompute/tc2/expected-test-results_ml_tensorflow:

Machine Learning Benchmark-Model unit tests
-------------------------------------------

Example result showcasing a typical machine learning inference flow using the TensorFlow Lite model benchmarking application, considering the "Mobile Object Localizer" model:

::

	# cd /opt/arm/ml
	# benchmark_model --graph=mobile_object_localizer_v1.tflite --num_threads=4 --num_runs=1 --min_secs=0.01
	INFO: STARTING!
	INFO: Log parameter values verbosely: [0]
	INFO: Min num runs: [1]
	INFO: Min runs duration (seconds): [0.01]
	INFO: Num threads: [4]
	INFO: Graph: [mobile_object_localizer_v1.tflite]
	INFO: #threads used for CPU inference: [4]
	INFO: Loaded model mobile_object_localizer_v1.tflite
	INFO: Created TensorFlow Lite XNNPACK delegate for CPU.
	INFO: The input model file size (MB): 1.86664
	INFO: Initialized session in 16.599ms.
	INFO: Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
	INFO: count=70 first=8539 curr=6894 min=6043 max=8539 avg=7181.07 std=656

	INFO: Running benchmark for at least 1 iterations and at least 0.01 seconds but terminate if exceeding 150 seconds.
	INFO: count=2 first=6449 curr=6510 min=6449 max=6510 avg=6479.5 std=30

	INFO: Inference timings in us: Init: 16599, First inference: 8539, Warmup (avg): 7181.07, Inference (avg): 6479.5
	INFO: Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
	INFO: Memory footprint delta from the start of the tool (MB): init=8.45312 overall=10.5898
	#


Similar example result enabling profiling model operators:

::

	# cd /opt/arm/ml
	# benchmark_model --graph=mobile_object_localizer_v1.tflite --num_threads=4 --num_runs=10 --min_secs=0.5 --enable_op_profiling=true
	INFO: STARTING!
	INFO: Log parameter values verbosely: [0]
	INFO: Min num runs: [10]
	INFO: Min runs duration (seconds): [0.5]
	INFO: Num threads: [4]
	INFO: Graph: [mobile_object_localizer_v1.tflite]
	INFO: Enable op profiling: [1]
	INFO: #threads used for CPU inference: [4]
	INFO: Loaded model mobile_object_localizer_v1.tflite
	INFO: Created TensorFlow Lite XNNPACK delegate for CPU.
	INFO: The input model file size (MB): 1.86664
	INFO: Initialized session in 16.772ms.
	INFO: Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
	INFO: count=67 first=8781 curr=7197 min=6335 max=9775 avg=7514.93 std=419

	INFO: Running benchmark for at least 10 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
	INFO: count=67 first=7176 curr=7505 min=6373 max=7775 avg=7454.97 std=256

	INFO: Inference timings in us: Init: 16772, First inference: 8781, Warmup (avg): 7514.93, Inference (avg): 7454.97
	INFO: Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
	INFO: Memory footprint delta from the start of the tool (MB): init=8.44922 overall=10.8789
	INFO: Profiling Info for Benchmark Initialization:
	============================== Run Order ==============================
			                         [node type]	  [first]	 [avg ms]	     [%]	  [cdf%]	  [mem KB]	[times called]	[Name]
			             ModifyGraphWithDelegate	   14.842	   14.842	 99.317%	 99.317%	  3428.000	        1	ModifyGraphWithDelegate/0
			                     AllocateTensors	    0.102	    0.102	  0.683%	100.000%	     0.000	        1	AllocateTensors/0

	============================== Top by Computation Time ==============================
			                         [node type]	  [first]	 [avg ms]	     [%]	  [cdf%]	  [mem KB]	[times called]	[Name]
			             ModifyGraphWithDelegate	   14.842	   14.842	 99.317%	 99.317%	  3428.000	        1	ModifyGraphWithDelegate/0
			                     AllocateTensors	    0.102	    0.102	  0.683%	100.000%	     0.000	        1	AllocateTensors/0

	Number of nodes executed: 2
	============================== Summary by node type ==============================
			                         [Node type]	  [count]	  [avg ms]	    [avg %]	    [cdf %]	  [mem KB]	[times called]
			             ModifyGraphWithDelegate	        1	    14.842	    99.317%	    99.317%	  3428.000	        1
			                     AllocateTensors	        1	     0.102	     0.683%	   100.000%	     0.000	        1

	Timings (microseconds): count=1 curr=14944
	Memory (bytes): count=0
	2 nodes observed



	INFO: Operator-wise Profiling Info for Regular Benchmark Runs:
	============================== Run Order ==============================
			                         [node type]	  [first]	 [avg ms]	     [%]	  [cdf%]	  [mem KB]	[times called]	[Name]
			       Convolution (NHWC, QU8) IGEMM	    0.267	    0.278	  3.783%	  3.783%	     0.000	        1	Delegate/Convolution (NHWC, QU8) IGEMM:0
			      Convolution (NHWC, QU8) DWConv	    0.243	    0.271	  3.681%	  7.464%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:1
			        Convolution (NHWC, QU8) GEMM	    0.089	    0.097	  1.314%	  8.778%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:2
			        Convolution (NHWC, QU8) GEMM	    0.324	    0.338	  4.598%	 13.375%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:3
			      Convolution (NHWC, QU8) DWConv	    0.190	    0.222	  3.012%	 16.387%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:4
			        Convolution (NHWC, QU8) GEMM	    0.092	    0.094	  1.281%	 17.668%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:5
			        Convolution (NHWC, QU8) GEMM	    0.174	    0.180	  2.452%	 20.120%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:6
			      Convolution (NHWC, QU8) DWConv	    0.300	    0.302	  4.099%	 24.219%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:7
			        Convolution (NHWC, QU8) GEMM	    0.124	    0.115	  1.565%	 25.783%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:8
			                       Add (ND, QU8)	    0.051	    0.051	  0.693%	 26.477%	     0.000	        1	Delegate/Add (ND, QU8):9
			        Convolution (NHWC, QU8) GEMM	    0.148	    0.158	  2.145%	 28.622%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:10
			      Convolution (NHWC, QU8) DWConv	    0.081	    0.101	  1.370%	 29.991%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:11
			        Convolution (NHWC, QU8) GEMM	    0.052	    0.083	  1.122%	 31.113%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:12
			        Convolution (NHWC, QU8) GEMM	    0.065	    0.098	  1.328%	 32.441%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:13
			      Convolution (NHWC, QU8) DWConv	    0.081	    0.104	  1.409%	 33.850%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:14
			        Convolution (NHWC, QU8) GEMM	    0.048	    0.087	  1.179%	 35.030%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:15
			                       Add (ND, QU8)	    0.012	    0.012	  0.164%	 35.193%	     0.000	        1	Delegate/Add (ND, QU8):16
			        Convolution (NHWC, QU8) GEMM	    0.059	    0.090	  1.225%	 36.418%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:17
			      Convolution (NHWC, QU8) DWConv	    0.104	    0.104	  1.408%	 37.826%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:18
			        Convolution (NHWC, QU8) GEMM	    0.076	    0.086	  1.175%	 39.001%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:19
			                       Add (ND, QU8)	    0.012	    0.012	  0.163%	 39.164%	     0.000	        1	Delegate/Add (ND, QU8):20
			        Convolution (NHWC, QU8) GEMM	    0.097	    0.090	  1.229%	 40.393%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:21
			      Convolution (NHWC, QU8) DWConv	    0.029	    0.055	  0.748%	 41.141%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:22
			        Convolution (NHWC, QU8) GEMM	    0.037	    0.033	  0.446%	 41.588%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:23
			        Convolution (NHWC, QU8) GEMM	    0.042	    0.066	  0.898%	 42.486%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:24
			      Convolution (NHWC, QU8) DWConv	    0.102	    0.063	  0.858%	 43.344%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:25
			        Convolution (NHWC, QU8) GEMM	    0.062	    0.057	  0.771%	 44.115%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:26
			                       Add (ND, QU8)	    0.006	    0.006	  0.082%	 44.196%	     0.000	        1	Delegate/Add (ND, QU8):27
			        Convolution (NHWC, QU8) GEMM	    0.028	    0.041	  0.557%	 44.753%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:28
			      Convolution (NHWC, QU8) DWConv	    0.068	    0.090	  1.227%	 45.980%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:29
			        Convolution (NHWC, QU8) GEMM	    0.030	    0.057	  0.768%	 46.747%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:30
			                       Add (ND, QU8)	    0.006	    0.006	  0.082%	 46.829%	     0.000	        1	Delegate/Add (ND, QU8):31
			        Convolution (NHWC, QU8) GEMM	    0.094	    0.041	  0.561%	 47.390%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:32
			      Convolution (NHWC, QU8) DWConv	    0.079	    0.092	  1.253%	 48.643%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:33
			        Convolution (NHWC, QU8) GEMM	    0.019	    0.055	  0.752%	 49.395%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:34
			                       Add (ND, QU8)	    0.006	    0.006	  0.082%	 49.477%	     0.000	        1	Delegate/Add (ND, QU8):35
			        Convolution (NHWC, QU8) GEMM	    0.094	    0.043	  0.583%	 50.060%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:36
			      Convolution (NHWC, QU8) DWConv	    0.098	    0.094	  1.276%	 51.335%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:37
			        Convolution (NHWC, QU8) GEMM	    0.069	    0.090	  1.229%	 52.564%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:38
			        Convolution (NHWC, QU8) GEMM	    0.081	    0.103	  1.397%	 53.962%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:39
			      Convolution (NHWC, QU8) DWConv	    0.058	    0.097	  1.320%	 55.281%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:40
			        Convolution (NHWC, QU8) GEMM	    0.091	    0.094	  1.275%	 56.556%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:41
			                       Add (ND, QU8)	    0.009	    0.009	  0.123%	 56.679%	     0.000	        1	Delegate/Add (ND, QU8):42
			        Convolution (NHWC, QU8) GEMM	    0.090	    0.091	  1.231%	 57.911%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:43
			      Convolution (NHWC, QU8) DWConv	    0.102	    0.099	  1.340%	 59.250%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:44
			        Convolution (NHWC, QU8) GEMM	    0.095	    0.095	  1.293%	 60.543%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:45
			                       Add (ND, QU8)	    0.009	    0.009	  0.123%	 60.666%	     0.000	        1	Delegate/Add (ND, QU8):46
			        Convolution (NHWC, QU8) GEMM	    0.093	    0.091	  1.232%	 61.898%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:47
			      Convolution (NHWC, QU8) DWConv	    0.025	    0.042	  0.564%	 62.462%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:48
			        Convolution (NHWC, QU8) GEMM	    0.066	    0.052	  0.709%	 63.171%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:49
			        Convolution (NHWC, QU8) GEMM	    0.104	    0.096	  1.301%	 64.472%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:50
			      Convolution (NHWC, QU8) DWConv	    0.069	    0.064	  0.869%	 65.341%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:51
			        Convolution (NHWC, QU8) GEMM	    0.031	    0.036	  0.495%	 65.836%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:52
			                       Add (ND, QU8)	    0.004	    0.004	  0.054%	 65.890%	     0.000	        1	Delegate/Add (ND, QU8):53
			        Convolution (NHWC, QU8) GEMM	    0.094	    0.093	  1.259%	 67.149%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:54
			      Convolution (NHWC, QU8) DWConv	    0.073	    0.055	  0.751%	 67.900%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:55
			        Convolution (NHWC, QU8) GEMM	    0.027	    0.045	  0.606%	 68.506%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:56
			                       Add (ND, QU8)	    0.004	    0.004	  0.054%	 68.560%	     0.000	        1	Delegate/Add (ND, QU8):57
			        Convolution (NHWC, QU8) GEMM	    0.094	    0.092	  1.249%	 69.809%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:58
			      Convolution (NHWC, QU8) DWConv	    0.073	    0.069	  0.939%	 70.747%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:59
			        Convolution (NHWC, QU8) GEMM	    0.106	    0.104	  1.416%	 72.164%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:60
			        Convolution (NHWC, QU8) GEMM	    0.120	    0.116	  1.581%	 73.745%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:61
			        Convolution (NHWC, QU8) GEMM	    0.101	    0.101	  1.374%	 75.119%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:62
			      Convolution (NHWC, QU8) DWConv	    0.005	    0.005	  0.064%	 75.183%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:63
			        Convolution (NHWC, QU8) GEMM	    0.009	    0.026	  0.352%	 75.535%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:64
			        Convolution (NHWC, QU8) GEMM	    0.012	    0.012	  0.164%	 75.700%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:65
			      Convolution (NHWC, QU8) DWConv	    0.001	    0.001	  0.014%	 75.713%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:66
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.002	  0.024%	 75.737%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:67
			        Convolution (NHWC, QU8) GEMM	    0.003	    0.002	  0.030%	 75.768%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:68
			      Convolution (NHWC, QU8) DWConv	    0.000	    0.000	  0.004%	 75.772%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:69
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 75.786%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:70
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 75.800%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:71
			      Convolution (NHWC, QU8) DWConv	    0.000	    0.000	  0.000%	 75.800%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:72
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 75.813%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:73
			      Convolution (NHWC, QU8) DWConv	    0.073	    0.056	  0.765%	 76.578%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:74
			      Convolution (NHWC, QU8) DWConv	    0.101	    0.096	  1.299%	 77.877%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:75
			      Convolution (NHWC, QU8) DWConv	    0.096	    0.081	  1.107%	 78.984%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:76
			      Convolution (NHWC, QU8) DWConv	    0.096	    0.066	  0.896%	 79.880%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:77
			      Convolution (NHWC, QU8) DWConv	    0.010	    0.012	  0.158%	 80.038%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:78
			      Convolution (NHWC, QU8) DWConv	    0.010	    0.009	  0.116%	 80.154%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:79
			      Convolution (NHWC, QU8) DWConv	    0.002	    0.002	  0.027%	 80.181%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:80
			      Convolution (NHWC, QU8) DWConv	    0.002	    0.002	  0.027%	 80.208%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:81
			      Convolution (NHWC, QU8) DWConv	    0.000	    0.000	  0.000%	 80.208%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:82
			      Convolution (NHWC, QU8) DWConv	    0.001	    0.001	  0.014%	 80.222%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:83
			      Convolution (NHWC, QU8) DWConv	    0.000	    0.000	  0.000%	 80.222%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:84
			      Convolution (NHWC, QU8) DWConv	    0.000	    0.000	  0.000%	 80.222%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:85
			        Convolution (NHWC, QU8) GEMM	    0.035	    0.028	  0.376%	 80.598%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:86
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 80.598%	     0.000	        1	Delegate/Copy (NC, X8):87
			        Convolution (NHWC, QU8) GEMM	    0.028	    0.030	  0.405%	 81.003%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:88
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.003%	     0.000	        1	Delegate/Copy (NC, X8):89
			        Convolution (NHWC, QU8) GEMM	    0.031	    0.029	  0.389%	 81.391%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:90
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.391%	     0.000	        1	Delegate/Copy (NC, X8):91
			        Convolution (NHWC, QU8) GEMM	    0.015	    0.015	  0.205%	 81.596%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:92
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.596%	     0.000	        1	Delegate/Copy (NC, X8):93
			        Convolution (NHWC, QU8) GEMM	    0.004	    0.004	  0.053%	 81.649%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:94
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.649%	     0.000	        1	Delegate/Copy (NC, X8):95
			        Convolution (NHWC, QU8) GEMM	    0.002	    0.002	  0.027%	 81.676%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:96
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.676%	     0.000	        1	Delegate/Copy (NC, X8):97
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 81.690%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:98
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.690%	     0.000	        1	Delegate/Copy (NC, X8):99
			        Convolution (NHWC, QU8) GEMM	    0.000	    0.000	  0.000%	 81.690%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:100
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.690%	     0.000	        1	Delegate/Copy (NC, X8):101
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 81.704%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:102
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.704%	     0.000	        1	Delegate/Copy (NC, X8):103
			        Convolution (NHWC, QU8) GEMM	    0.000	    0.000	  0.000%	 81.704%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:104
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.704%	     0.000	        1	Delegate/Copy (NC, X8):105
			        Convolution (NHWC, QU8) GEMM	    0.001	    0.001	  0.014%	 81.717%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:106
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.717%	     0.000	        1	Delegate/Copy (NC, X8):107
			        Convolution (NHWC, QU8) GEMM	    0.000	    0.000	  0.000%	 81.717%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:108
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.717%	     0.000	        1	Delegate/Copy (NC, X8):109
			                       CONCATENATION	    0.004	    0.004	  0.049%	 81.766%	     0.000	        1	[concat_1]:108
			                       CONCATENATION	    0.002	    0.003	  0.037%	 81.803%	     0.000	        1	[concat]:112
			                       Copy (NC, X8)	    0.000	    0.000	  0.000%	 81.803%	     0.000	        1	Delegate/Copy (NC, X8):0
			                   Sigmoid (NC, QU8)	    0.000	    0.000	  0.000%	 81.803%	     0.000	        1	Delegate/Sigmoid (NC, QU8):1
			        TFLite_Detection_PostProcess	    1.342	    1.339	 18.197%	100.000%	     0.000	        1	[TFLite_Detection_PostProcess, TFLite_Detection_PostProcess:1, TFLite_Detection_PostProcess:2, TFLite_Detection_PostProcess:3]:114

	============================== Top by Computation Time ==============================
			                         [node type]	  [first]	 [avg ms]	     [%]	  [cdf%]	  [mem KB]	[times called]	[Name]
			        TFLite_Detection_PostProcess	    1.342	    1.339	 18.197%	 18.197%	     0.000	        1	[TFLite_Detection_PostProcess, TFLite_Detection_PostProcess:1, TFLite_Detection_PostProcess:2, TFLite_Detection_PostProcess:3]:114
			        Convolution (NHWC, QU8) GEMM	    0.324	    0.338	  4.598%	 22.795%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:3
			      Convolution (NHWC, QU8) DWConv	    0.300	    0.302	  4.099%	 26.894%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:7
			       Convolution (NHWC, QU8) IGEMM	    0.267	    0.278	  3.783%	 30.678%	     0.000	        1	Delegate/Convolution (NHWC, QU8) IGEMM:0
			      Convolution (NHWC, QU8) DWConv	    0.243	    0.271	  3.681%	 34.358%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:1
			      Convolution (NHWC, QU8) DWConv	    0.190	    0.222	  3.012%	 37.370%	     0.000	        1	Delegate/Convolution (NHWC, QU8) DWConv:4
			        Convolution (NHWC, QU8) GEMM	    0.174	    0.180	  2.452%	 39.822%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:6
			        Convolution (NHWC, QU8) GEMM	    0.148	    0.158	  2.145%	 41.967%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:10
			        Convolution (NHWC, QU8) GEMM	    0.120	    0.116	  1.581%	 43.548%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:61
			        Convolution (NHWC, QU8) GEMM	    0.124	    0.115	  1.565%	 45.113%	     0.000	        1	Delegate/Convolution (NHWC, QU8) GEMM:8

	Number of nodes executed: 115
	============================== Summary by node type ==============================
			                         [Node type]	  [count]	  [avg ms]	    [avg %]	    [cdf %]	  [mem KB]	[times called]
			        Convolution (NHWC, QU8) GEMM	       54	     3.340	    45.622%	    45.622%	     0.000	       54
			      Convolution (NHWC, QU8) DWConv	       33	     2.240	    30.597%	    76.219%	     0.000	       33
			        TFLite_Detection_PostProcess	        1	     1.339	    18.290%	    94.509%	     0.000	        1
			       Convolution (NHWC, QU8) IGEMM	        1	     0.278	     3.797%	    98.306%	     0.000	        1
			                       Add (ND, QU8)	       10	     0.119	     1.625%	    99.932%	     0.000	       10
			                       CONCATENATION	        2	     0.005	     0.068%	   100.000%	     0.000	        2
			                   Sigmoid (NC, QU8)	        1	     0.000	     0.000%	   100.000%	     0.000	        1
			                       Copy (NC, X8)	       13	     0.000	     0.000%	   100.000%	     0.000	       13

	Timings (microseconds): count=67 first=7068 curr=7410 min=6282 max=7683 avg=7360.09 std=256
	Memory (bytes): count=0
	115 nodes observed

	#

.. _docs/totalcompute/tc2/expected-test-results_optee:


OP-TEE unit tests
-----------------

::

	# xtest
	Run test suite with level=0

	TEE test application started over default TEE instance
	######################################################
	#
	# regression
	#
	######################################################

	* regression_1001 Core self tests
	 - 1001 -   skip test, pseudo TA not found
	  regression_1001 OK

	* regression_1002 PTA parameters
	 - 1002 -   skip test, pseudo TA not found
	  regression_1002 OK

	(...output truncated...)

	regression_8101 OK
	regression_8102 OK
	regression_8103 OK
	+-----------------------------------------------------
	26197 subtests of which 0 failed
	104 test cases of which 0 failed
	0 test cases were skipped
	TEE test application done!
	#

.. _docs/totalcompute/tc2/expected-test-results_ts:


Trusted Services and Client application unit tests
--------------------------------------------------

Expected command output for the Trusted Services:

::

	# ts-service-test -sg ItsServiceTests -sg PsaCryptoApiTests -sg CryptoServicePackedcTests -sg CryptoServiceProtobufTests -sg CryptoServiceLimitTests -v
	TEST(ItsServiceTests, storeNewItem) - 3903 ms
	TEST(CryptoServicePackedcTests, generateRandomNumbers) - 8063 ms
	TEST(CryptoServicePackedcTests, asymEncryptDecryptWithSalt) - 46995 ms
	TEST(CryptoServicePackedcTests, asymEncryptDecrypt) - 11187 ms
	TEST(CryptoServicePackedcTests, signAndVerifyEat) - 36934 ms
	TEST(CryptoServicePackedcTests, signAndVerifyMessage) - 37118 ms
	TEST(CryptoServicePackedcTests, signAndVerifyHash) - 37121 ms
	TEST(CryptoServicePackedcTests, exportAndImportKeyPair) - 5506 ms
	TEST(CryptoServicePackedcTests, exportPublicKey) - 7416 ms
	TEST(CryptoServicePackedcTests, purgeKey) - 4631 ms
	TEST(CryptoServicePackedcTests, copyKey) - 12366 ms
	TEST(CryptoServicePackedcTests, generatePersistentKeys) - 8316 ms
	TEST(CryptoServicePackedcTests, generateVolatileKeys) - 7886 ms
	TEST(CryptoServiceProtobufTests, generateRandomNumbers) - 5785 ms
	TEST(CryptoServiceProtobufTests, asymEncryptDecryptWithSalt) - 59963 ms
	TEST(CryptoServiceProtobufTests, asymEncryptDecrypt) - 15982 ms
	TEST(CryptoServiceProtobufTests, signAndVerifyMessage) - 37117 ms
	TEST(CryptoServiceProtobufTests, signAndVerifyHash) - 37177 ms
	TEST(CryptoServiceProtobufTests, exportAndImportKeyPair) - 5562 ms
	TEST(CryptoServiceProtobufTests, exportPublicKey) - 7467 ms
	TEST(CryptoServiceProtobufTests, generatePersistentKeys) - 8378 ms
	TEST(CryptoServiceProtobufTests, generateVolatileKeys) - 7896 ms
	TEST(CryptoServiceLimitTests, volatileRsaKeyPairLimit) - 814715 ms
	TEST(CryptoServiceLimitTests, volatileEccKeyPairLimit) - 197333 ms

	OK (43 tests, 24 ran, 206 checks, 0 ignored, 19 filtered out, 1425193 ms)

	#


Expected command output for the Client application:

::

	# ts-demo

	Demonstrates use of trusted services from an application
	---------------------------------------------------------
	A client requests a set of crypto operations performed by
	the Crypto service.  Key storage for persistent keys is
	provided by the Secure Storage service via the ITS client.

	Generating random bytes length: 1
		    Operation successful
		    Random bytes:
		            2B
	Generating random bytes length: 7
		    Operation successful
		    Random bytes:
		            68 CF 0C 5D 87 C7 11
	Generating random bytes length: 128
		    Operation successful
		    Random bytes:
		            BF C6 85 27 81 02 5F 83
		            60 97 E9 2C A6 30 8E F7
		            C6 81 44 CB 26 32 8D F5
		            62 BA 0F DE B8 2C 69 E2
		            DD C0 FF A0 04 E2 D0 C0
		            DC EA 11 CE DD 7E 33 87
		            62 07 89 02 00 68 FC 24
		            AD D2 E4 86 40 3F 6E 65
		            83 46 33 9A F8 84 14 3B
		            72 11 8D 63 59 6F 69 96
		            70 D2 83 8D 60 6D 9F A2
		            B3 54 F6 3E 5E B3 FE 07
		            C9 51 F1 6A F5 B0 0E AA
		            08 B3 AE F5 06 73 6C 8B
		            95 73 B2 FF 72 C6 CF 84
		            12 7A 7A 1F 07 F2 58 71
	Generating ECC signing key
		    Operation successful
	Signing message: "The quick brown fox" using key: 256
		    Operation successful
		    Signature bytes:
		            F9 F7 0E D0 4A B2 77 DF
		            67 40 F5 36 4D 92 38 A3
		            13 5B 04 A0 6C BD 84 40
		            03 E2 43 EE BF 6F C6 C4
		            5B 5D A4 21 D9 EB 17 86
		            B9 71 0D C9 84 0C FE 55
		            71 8E 5C F7 D4 7D EB 04
		            9B 5A 11 D7 46 96 BD A6
	Verify signature using original message: "The quick brown fox"
		    Operation successful
	Verify signature using modified message: "!he quick brown fox"
		    Successfully detected modified message
	Signing message: "jumps over the lazy dog" using key: 256
		    Operation successful
		    Signature bytes:
		            45 40 14 E3 39 0C 3B 8A
		            5F 05 C8 0C E0 B6 A6 D2
		            8B 5E E3 76 49 DD F1 9E
		            50 A0 77 6F 1B FA FF C8
		            38 66 6A 2D 40 B1 79 9C
		            43 BE 59 F4 48 45 A2 0E
		            D0 17 3F 1F D3 D7 C0 84
		            65 AC 9B 8A FB 6E B6 B6
	Verify signature using original message: "jumps over the lazy dog"
		    Operation successful
	Verify signature using modified message: "!umps over the lazy dog"
		    Successfully detected modified message
	Generating RSA encryption key
		    Operation successful
	Encrypting message: "Top secret" using RSA key: 257
		    Operation successful
		    Encrypted message:
		            42 B6 53 D8 A3 03 BB 64
		            66 C0 31 A5 42 2C F8 F3
		            B8 E3 9C 58 42 7C 2C E0
		            19 43 F6 02 EB 60 6A DC
	Decrypting message using RSA key: 257
		    Operation successful
		    Decrypted message: "Top secret"
	Exporting public key: 256
		    Operation successful
		    Public key bytes:
		            04 D0 9A AF 76 18 9B 3B
		            08 38 65 BA 5F 81 B0 85
		            6A 39 42 19 5F 0D 17 86
		            CD 7E 2A E6 A4 CC A2 E4
		            B3 78 89 76 F6 CA 02 12
		            CB 07 2B AB CF 03 59 B3
		            34 8D 5D 0F 31 53 E0 68
		            9D 25 E2 AF 2E 0C 2C BE
		            51
	Destroying signing key: 256
		    Operation successful
	Destroying encryption key: 257
		    Operation successful
	#

.. _docs/totalcompute/tc2/expected-test-results_trusty:


Trusty unit tests
-----------------

::

	console:/ # tipc-test -t ta2ta-ipc
	ta2ta_ipc_test:
	ipc-unittest-main: 2556: first_free_handle_index: 3
	ipc-unittest-main: 2540: retry ret 0, event handle 1000, event 0x1
	ipc-unittest-main: 2543: nested ret -13, event handle 1000, event 0x1
	[ RUN      ] ipc.wait_negative
	[       OK ] ipc.wait_negative
	[ RUN      ] ipc.close_handle_negative
	[       OK ] ipc.close_handle_negative
	[ RUN      ] ipc.set_cookie_negative
	[       OK ] ipc.set_cookie_negative
	[ RUN      ] ipc.port_create_negative
	[       OK ] ipc.port_create_negative
	[ RUN      ] ipc.port_create
	[       OK ] ipc.port_create
	[ RUN      ] ipc.connect_negative
	[       OK ] ipc.connect_negative
	[ RUN      ] ipc.connect_close
	[       OK ] ipc.connect_close
	[ RUN      ] ipc.connect_access
	[       OK ] ipc.connect_access
	[ RUN      ] ipc.accept_negative
	[       OK ] ipc.accept_negative
	[ DISABLED ] ipc.DISABLED_accept
	[ RUN      ] ipc.get_msg_negative
	[       OK ] ipc.get_msg_negative
	[ RUN      ] ipc.put_msg_negative
	[       OK ] ipc.put_msg_negative
	[ RUN      ] ipc.send_msg
	[       OK ] ipc.send_msg
	[ RUN      ] ipc.send_msg_negative
	[       OK ] ipc.send_msg_negative
	[ RUN      ] ipc.read_msg_negative
	[       OK ] ipc.read_msg_negative
	[ RUN      ] ipc.end_to_end_msg
	[       OK ] ipc.end_to_end_msg
	[ RUN      ] ipc.hset_create
	[       OK ] ipc.hset_create
	[ RUN      ] ipc.hset_add_mod_del
	[       OK ] ipc.hset_add_mod_del
	[ RUN      ] ipc.hset_add_self
	[       OK ] ipc.hset_add_self
	[ RUN      ] ipc.hset_add_loop
	[       OK ] ipc.hset_add_loop
	[ RUN      ] ipc.hset_add_duplicate
	[       OK ] ipc.hset_add_duplicate
	[ RUN      ] ipc.hset_wait_on_empty_set
	[       OK ] ipc.hset_wait_on_empty_set
	[ DISABLED ] ipc.DISABLED_hset_add_chan
	[ RUN      ] ipc.send_handle_negative
	[       OK ] ipc.send_handle_negative
	[ RUN      ] ipc.recv_handle
	[       OK ] ipc.recv_handle
	[ RUN      ] ipc.recv_handle_negative
	[       OK ] ipc.recv_handle_negative
	[ RUN      ] ipc.echo_handle_bulk
	[       OK ] ipc.echo_handle_bulk
	[ RUN      ] ipc.tipc_connect
	[       OK ] ipc.tipc_connect
	[ RUN      ] ipc.tipc_send_recv_1
	[       OK ] ipc.tipc_send_recv_1
	[ RUN      ] ipc.tipc_send_recv_hdr_payload
	[       OK ] ipc.tipc_send_recv_hdr_payload
	[==========] 28 tests ran.
	[  PASSED  ] 28 tests.
	[ DISABLED ] 2 tests.
	console:/ # 

.. _docs/totalcompute/tc2/expected-test-results_microdroid:


Microdroid Demo unit tests
--------------------------

::

	INFO: ADB connecting to 127.0.0.1:5555
	INFO: ADB connected to 127.0.0.1:5555
	INFO: Checking ro.product.name
	INFO: ro.product.name matches tc_fvp
	INFO: Checking path of com.android.microdroid.tc
	INFO: APK Installed path is: /system/app/TCMicrodroidDemoApp/TCMicrodroidDemoApp.apk
	Created VM from "/system/app/TCMicrodroidDemoApp/TCMicrodroidDemoApp.apk"!"assets/vm_config.json" with CID 10, state is NOT_STARTED.
	Started VM, state now STARTING.


	U-Boot 2022.01-15068-g240b124907 (Apr 14 2022 - 14:14:27 +0000)

	DRAM:  256 MiB
	## Android Verified Boot 2.0 version 1.1.0
	read_is_device_unlocked not supported yet
	read_rollback_index not supported yet
	read_rollback_index not supported yet
	read_rollback_index not supported yet
	read_is_device_unlocked not supported yet
	Verification passed successfully
	Imported supplementary environment
	Could not find "misc" partition
	## Android Verified Boot 2.0 version 1.1.0
	read_is_device_unlocked not supported yet
	read_rollback_index not supported yet
	read_is_device_unlocked not supported yet
	Verification passed successfully
	## Android Verified Boot 2.0 version 1.1.0
	read_is_device_unlocked not supported yet
	read_rollback_index not supported yet
	read_rollback_index not supported yet
	read_rollback_index not supported yet
	read_is_device_unlocked not supported yet
	Verification passed successfully
	ANDROID: Loading vendor ramdisk from "vendor_boot_a", partition 3.
	Booting kernel at 0x80200000 with fdt at 80000000 ramdisk 0x84200000:0x00195c30...


	## Flattened Device Tree blob at 80000000
	   Booting using the fdt blob at 0x80000000
	   Loading Ramdisk to 8eadb000, end 8ec70c30 ... OK
	   Loading Device Tree to 000000008ead7000, end 000000008eadab80 ... OK

	Starting kernel ...

	[    0.136679][    T1] virtio_blk virtio3: [vda] 192768 512-byte logical blocks (98.7 MB/94.1 MiB)
	[    0.136743][    T1] vda: detected capacity change from 0 to 98697216
	[    0.153152][    T1] GPT:Primary header thinks Alt. header is not at the end of the disk.
	[    0.153207][    T1] GPT:192712 != 192767
	[    0.153244][    T1] GPT:Alternate GPT header not at the end of the disk.
	[    0.153312][    T1] GPT:192712 != 192767
	[    0.153348][    T1] GPT: Use GNU Parted to correct GPT errors.
	[    0.153393][    T1]  vda: vda1 vda2 vda3 vda4 vda5
	[    0.156140][    T1] virtio_blk virtio4: [vdb] 20992 512-byte logical blocks (10.7 MB/10.3 MiB)
	[    0.156265][    T1] vdb: detected capacity change from 0 to 10747904
	[    0.197172][    T1] GPT:Primary header thinks Alt. header is not at the end of the disk.
	[    0.197566][    T1] GPT:20968 != 20991
	[    0.197817][    T1] GPT:Alternate GPT header not at the end of the disk.
	[    0.198281][    T1] GPT:20968 != 20991
	[    0.198585][    T1] GPT: Use GNU Parted to correct GPT errors.
	[    0.198969][    T1]  vdb: vdb1 vdb2 vdb3 vdb4
	[    0.201812][    T1] virtio_blk virtio5: [vdc] 3968 512-byte logical blocks (2.03 MB/1.94 MiB)
	[    0.202210][    T1] vdc: detected capacity change from 0 to 2031616
	[    0.226878][    T1] GPT:Primary header thinks Alt. header is not at the end of the disk.
	[    0.227043][    T1] GPT:3872 != 3967
	[    0.227141][    T1] GPT:Alternate GPT header not at the end of the disk.
	[    0.227301][    T1] GPT:3872 != 3967
	[    0.227399][    T1] GPT: Use GNU Parted to correct GPT errors.
	[    0.227544][    T1]  vdc: vdc1 vdc2 vdc3 vdc4
	[    0.242286][    T1] device-mapper: verity: sha1 using implementation "sha1-generic"
	[    0.250605][    T1] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: errors=panic
	[    0.252168][    T1] device-mapper: verity: sha1 using implementation "sha1-generic"
	[    0.254868][    T1] EXT4-fs (dm-3): mounted filesystem without journal. Opts: errors=panic
	[    0.350347][    T1] SELinux:  Permission nlmsg_getneigh in class netlink_route_socket not defined in policy.
	[    0.350480][    T1] SELinux:  Permission bpf in class capability2 not defined in policy.
	[    0.350556][    T1] SELinux:  Permission checkpoint_restore in class capability2 not defined in policy.
	[    0.350652][    T1] SELinux:  Permission bpf in class cap2_userns not defined in policy.
	[    0.350765][    T1] SELinux:  Permission checkpoint_restore in class cap2_userns not defined in policy.
	[    0.350898][    T1] SELinux: the above unknown classes and permissions will be denied
	[    0.353749][    T1] SELinux:  policy capability network_peer_controls=1
	[    0.353824][    T1] SELinux:  policy capability open_perms=1
	[    0.353878][    T1] SELinux:  policy capability extended_socket_class=1
	[    0.353974][    T1] SELinux:  policy capability always_check_network=0
	[    0.354040][    T1] SELinux:  policy capability cgroup_seclabel=0
	[    0.354113][    T1] SELinux:  policy capability nnp_nosuid_transition=1
	[    0.354210][    T1] SELinux:  policy capability genfs_seclabel_symlinks=0
	[    0.500954][   T21] audit: type=1403 audit(1682216952.892:2): auid=4294967295 ses=4294967295 lsm=selinux res=1
	[    0.507132][   T21] audit: type=1404 audit(1682216952.896:3): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295 enabled=1 old-enabled=1 lsm=selinux res=1
	[    0.705758][  T128] binder: 128:128 transaction failed 29189/-22, size 0-0 line 2758
	[    0.705896][  T129] binder: 129:129 transaction failed 29189/-22, size 0-0 line 2758
	[    0.730365][  T131] device-mapper: verity: sha256 using implementation "sha256-ce"
	[    0.770587][    C0] blk_update_request: I/O error, dev vdc, sector 0 op 0x1:(WRITE) flags 0x800 phys_seg 0 prio class 0
	[    0.773769][  T137] device-mapper: verity: sha256 using implementation "sha256-ce"
	[    0.795051][  T137] EXT4-fs (dm-5): mounted filesystem without journal. Opts: (null)
	[    0.800970][  T137] EXT4-fs (loop2): mounted filesystem without journal. Opts: (null)
	libc: Access denied finding property "persist.arm64.memtag.default"
	libc: Access denied finding property "libc.debug.gwp_asan.sample_rate.microdroid_launcher"
	libc: Access denied finding property "libc.debug.gwp_asan.sample_rate.system_default"
	libc: Access denied finding property "libc.debug.gwp_asan.process_sampling.microdroid_launcher"
	libc: Access denied finding property "libc.debug.gwp_asan.process_sampling.system_default"
	libc: Access denied finding property "libc.debug.gwp_asan.max_allocs.microdroid_launcher"
	libc: Access denied finding property "libc.debug.gwp_asan.max_allocs.system_default"
	libc: Access denied finding property "heapprofd.enable"
	libc: Access denied finding property "ro.arch"
	libc: Access denied finding property "ro.arch"
	libc: Access denied finding property "ro.arch"
	[    1.826111][   T21] audit: type=1400 audit(1682216954.216:4): avc:  denied  { getattr } for  pid=152 comm="microdroid_laun" path="socket:[11462]" dev="sockfs" ino=11462 scontext=u:r:microdroid_app:s0 tcontext=u:r:microdroid_manager:s0 tclass=vsock_socket permissive=0
	Hello Microdroid!
	payload finished with exit code 0
	[    1.829062][   T18] binder: undelivered transaction 38, process died.

.. _docs/totalcompute/tc2/expected-test-results_kernel:


Kernel selftest unit tests
--------------------------

::

	# ./run_kselftest.sh --summary
	[  407.778719][  T234] kselftest: Running tests in arm64
	TAP version 13
	1..10
	# selftests: arm64: check_gcr_el1_cswitch
	ok 1 selftests: arm64: check_gcr_el1_cswitch
	# selftests: arm64: check_ksm_options
	not ok 2 selftests: arm64: check_ksm_options # exit=1
	# selftests: arm64: check_tags_inclusion
	ok 3 selftests: arm64: check_tags_inclusion
	# selftests: arm64: check_user_mem
	ok 4 selftests: arm64: check_user_mem
	# selftests: arm64: check_mmap_options
	ok 5 selftests: arm64: check_mmap_options
	# selftests: arm64: check_child_memory
	ok 6 selftests: arm64: check_child_memory
	# selftests: arm64: check_buffer_fill
	ok 7 selftests: arm64: check_buffer_fill
	# selftests: arm64: btitest
	ok 8 selftests: arm64: btitest
	# selftests: arm64: nobtitest
	ok 9 selftests: arm64: nobtitest
	# selftests: arm64: pac
	ok 10 selftests: arm64: pac
	# 

.. _docs/totalcompute/tc2/expected-test-results_mpam:


MPAM unit tests
---------------

::

	# testing_mpam.sh
	Testing the number of partitions supported.  It should be 0-63
	Pass

	Partition 0 is the default partition to which all tasks will be assigned.  Checking if task 5 is assigned to partition 0
	Pass

	Testing the number of bits required to set the cache portion bitmap. It should be 8
	Pass

	Testing the default cpbm configured in the DSU for all the partitions.  It should be 0-7 for all the partitions
	[  305.081818][  T236] MPAM_arch: PART_SEL: 0x0
	Pass

	Setting the cpbm 4-5 (00110000) in DSU for partition 45 and reading it back
	[  305.081969][  T233] MPAM_arch: PART_SEL: 0x2d
	[  305.081974][  T233] MPAM_arch: CPBM: 0x30 @ffff80000a803000
	[  305.082588][  T237] MPAM_arch: PART_SEL: 0x2d
	Pass

	#

.. _docs/totalcompute/tc2/expected-test-results_mpmm:


MPMM unit tests
---------------

::

    # test_mpmm.sh fvp
    This is a test script to check the MPMM functionality

    This is based on the PCT configured in the SCP which can be found at
    product/tc2/scp_ramfw/config_mpmm.c

    Testing MPMM in FVP

    Testing the MPMM of A520 cores
    ******************************
    According to the PCT, the max frequency should be 1840000
    Current set frequency of the cpu0 is 1537000
    PASS

    Starting a vector intensive workload on cpu0
    According to the PCT, the max frequency should be 1537000
    Current set frequency of the cpu0 is 1537000
    PASS

    Starting a vector intensive workload on cpu1
    According to the PCT, the max frequency should be 1537000
    Current set frequency of the cpu0 is 1537000
    PASS

    Starting a vector intensive workload on cpu2
    According to the PCT, the max frequency should be 1153000
    Current set frequency of the cpu0 is 1153000
    PASS

    Starting a vector intensive workload on cpu3
    According to the PCT, the max frequency should be 1153000
    Current set frequency of the cpu0 is 1153000
    PASS

    Testing the MPMM of A720 cores
    ******************************
    According to the PCT, the max frequency should be 2271000
    Current set frequency of the cpu4 is 1893000
    PASS

    Starting a vector intensive workload on cpu4
    According to the PCT, the max frequency should be 1893000
    Current set frequency of the cpu4 is 1893000
    PASS

    Starting a vector intensive workload on cpu5
    According to the PCT, the max frequency should be 1893000
    Current set frequency of the cpu4 is 1893000
    PASS

    Starting a vector intensive workload on cpu6
    According to the PCT, the max frequency should be 1893000
    Current set frequency of the cpu4 is 1893000
    PASS

    Testing the MPMM of X4 cores
    ******************************
    According to the PCT, the max frequency should be 3047000
    Current set frequency of the cpu7 is 1088000
    PASS

    Starting a vector intensive workload on cpu7
    According to the PCT, the max frequency should be 2612000
    Current set frequency of the cpu7 is 2612000
    PASS
    #

.. _docs/totalcompute/tc2/expected-test-results_bti:


BTI unit tests
--------------

::

	console:/data/nativetest64/bti-unit-tests # ./bti-unit-tests

	[==========] Running 17 tests from 7 test suites.
	[----------] Global test environment set-up.
	[----------] 3 tests from BR_Test
	[ RUN      ] BR_Test.GuardedMemoryWithX16OrX17
	[       OK ] BR_Test.GuardedMemoryWithX16OrX17 (181 ms)
	[ RUN      ] BR_Test.NonGuardedMemoryAnyRegister
	[       OK ] BR_Test.NonGuardedMemoryAnyRegister (0 ms)
	[ RUN      ] BR_Test.GuardedMemoryOtherRegisters
	[       OK ] BR_Test.GuardedMemoryOtherRegisters (122 ms)
	[----------] 3 tests from BR_Test (304 ms total)

	[----------] 3 tests from BRAA_Test
	[ RUN      ] BRAA_Test.GuardedMemoryWithX16OrX17
	[       OK ] BRAA_Test.GuardedMemoryWithX16OrX17 (344 ms)
	[ RUN      ] BRAA_Test.NonGuardedMemoryAnyRegister
	[       OK ] BRAA_Test.NonGuardedMemoryAnyRegister (0 ms)
	[ RUN      ] BRAA_Test.GuardedMemoryOtherRegisters
	[       OK ] BRAA_Test.GuardedMemoryOtherRegisters (233 ms)
	[----------] 3 tests from BRAA_Test (578 ms total)

	[----------] 3 tests from BRAB_Test
	[ RUN      ] BRAB_Test.GuardedMemoryWithX16OrX17
	[       OK ] BRAB_Test.GuardedMemoryWithX16OrX17 (310 ms)
	[ RUN      ] BRAB_Test.NonGuardedMemoryAnyRegister
	[       OK ] BRAB_Test.NonGuardedMemoryAnyRegister (0 ms)
	[ RUN      ] BRAB_Test.GuardedMemoryOtherRegisters
	[       OK ] BRAB_Test.GuardedMemoryOtherRegisters (297 ms)
	[----------] 3 tests from BRAB_Test (608 ms total)

	[----------] 2 tests from BLR_Test
	[ RUN      ] BLR_Test.GuardedMemoryAnyRegister
	[       OK ] BLR_Test.GuardedMemoryAnyRegister (332 ms)
	[ RUN      ] BLR_Test.NonGuardedMemoryAnyRegister
	[       OK ] BLR_Test.NonGuardedMemoryAnyRegister (0 ms)
	[----------] 2 tests from BLR_Test (333 ms total)

	[----------] 2 tests from BLRAA_Test
	[ RUN      ] BLRAA_Test.GuardedMemoryAnyRegister

	[       OK ] BLRAA_Test.GuardedMemoryAnyRegister (745 ms)
	[ RUN      ] BLRAA_Test.NonGuardedMemoryAnyRegister
	[       OK ] BLRAA_Test.NonGuardedMemoryAnyRegister (0 ms)
	[----------] 2 tests from BLRAA_Test (745 ms total)

	[----------] 2 tests from BLRAB_Test
	[ RUN      ] BLRAB_Test.GuardedMemoryAnyRegister
	[       OK ] BLRAB_Test.GuardedMemoryAnyRegister (748 ms)
	[ RUN      ] BLRAB_Test.NonGuardedMemoryAnyRegister
	[       OK ] BLRAB_Test.NonGuardedMemoryAnyRegister (0 ms)
	[----------] 2 tests from BLRAB_Test (748 ms total)

	[----------] 2 tests from BTI_LinkerTest
	[ RUN      ] BTI_LinkerTest.CallBasicFunction
	[       OK ] BTI_LinkerTest.CallBasicFunction (0 ms)
	[ RUN      ] BTI_LinkerTest.BypassLandingPad
	[       OK ] BTI_LinkerTest.BypassLandingPad (35 ms)
	[----------] 2 tests from BTI_LinkerTest (35 ms total)

	[----------] Global test environment tear-down
	[==========] 17 tests from 7 test suites ran. (3354 ms total)
	[  PASSED  ] 17 tests.

.. _docs/totalcompute/tc2/expected-test-results_mte:


MTE unit tests
--------------

::

	console:/data/nativetest64/mte-unit-tests # ./mte-unit-tests

	[==========] Running 12 tests from 1 test suite.
	[----------] Global test environment set-up.
	[----------] 12 tests from MTETest
	[ RUN      ] MTETest.CreateRandomTag
	[       OK ] MTETest.CreateRandomTag (0 ms)
	[ RUN      ] MTETest.IncrementTag
	[       OK ] MTETest.IncrementTag (0 ms)
	[ RUN      ] MTETest.ExcludedTags
	[       OK ] MTETest.ExcludedTags (0 ms)
	[ RUN      ] MTETest.PointerSubtraction
	[       OK ] MTETest.PointerSubtraction (0 ms)
	[ RUN      ] MTETest.TagStoreAndLoad
	[       OK ] MTETest.TagStoreAndLoad (0 ms)
	[ RUN      ] MTETest.DCGZVA
	[       OK ] MTETest.DCGZVA (0 ms)
	[ RUN      ] MTETest.DCGVA
	[       OK ] MTETest.DCGVA (0 ms)
	[ RUN      ] MTETest.Segfault
	[       OK ] MTETest.Segfault (41 ms)
	[ RUN      ] MTETest.UseAfterFree
	[       OK ] MTETest.UseAfterFree (0 ms)
	[ RUN      ] MTETest.CopyOnWrite
	[       OK ] MTETest.CopyOnWrite (0 ms)
	[ RUN      ] MTETest.mmapTempfile
	[       OK ] MTETest.mmapTempfile (5 ms)
	[ RUN      ] MTETest.MTEIsEnabled
	[       OK ] MTETest.MTEIsEnabled (0 ms)
	[----------] 12 tests from MTETest (48 ms total)

	[----------] Global test environment tear-down
	[==========] 12 tests from 1 test suite ran. (48 ms total)
	[  PASSED  ] 12 tests.

.. _docs/totalcompute/tc2/expected-test-results_pauth:


PAUTH unit tests
-----------------

::

	console:/data/nativetest64/pauth-unit-tests $ ./pauth-unit-tests
	PAC is enabled by the kernel: 1
	PAC2 is implemented by the hardware: 1
	FPAC is implemented by the hardware: 1
	[==========] Running 18 tests from 3 test suites.
	[----------] Global test environment set-up.
	[----------] 2 tests from PAuthDeathTest
	[ RUN      ] PAuthDeathTest.SignFailure
	[       OK ] PAuthDeathTest.SignFailure (113 ms)
	[ RUN      ] PAuthDeathTest.AuthFailure
	[       OK ] PAuthDeathTest.AuthFailure (137 ms)
	[----------] 2 tests from PAuthDeathTest (250 ms total)

	[----------] 13 tests from PAuthTest
	[ RUN      ] PAuthTest.Signing
	[       OK ] PAuthTest.Signing (0 ms)
	[ RUN      ] PAuthTest.Authentication
	[       OK ] PAuthTest.Authentication (146 ms)
	[ RUN      ] PAuthTest.Stripping
	vendor/arm/examples/pauth/pauth_unit_tests/pauth_unit_tests.cpp:279: Skipped

	[  SKIPPED ] PAuthTest.Stripping (0 ms)
	[ RUN      ] PAuthTest.Roundtrip
	[       OK ] PAuthTest.Roundtrip (0 ms)
	[ RUN      ] PAuthTest.StrippingWithBuiltinReturnAddress
	[       OK ] PAuthTest.StrippingWithBuiltinReturnAddress (0 ms)
	[ RUN      ] PAuthTest.ExtractPAC
	[       OK ] PAuthTest.ExtractPAC (0 ms)
	[ RUN      ] PAuthTest.PACMask
	[       OK ] PAuthTest.PACMask (0 ms)
	[ RUN      ] PAuthTest.KeyChange
	[       OK ] PAuthTest.KeyChange (1 ms)
	[ RUN      ] PAuthTest.GenericAuthentication
	[       OK ] PAuthTest.GenericAuthentication (0 ms)
	[ RUN      ] PAuthTest.Unwind
	[       OK ] PAuthTest.Unwind (8 ms)
	[ RUN      ] PAuthTest.CheckReturnAddressSigned
	[       OK ] PAuthTest.CheckReturnAddressSigned (0 ms)
	[ RUN      ] PAuthTest.AuthenticateThenReturn
	[       OK ] PAuthTest.AuthenticateThenReturn (93 ms)
	[ RUN      ] PAuthTest.CheckHWCAP
	[       OK ] PAuthTest.CheckHWCAP (0 ms)
	[----------] 13 tests from PAuthTest (251 ms total)

	[----------] 3 tests from PAuthTestData
	[ RUN      ] PAuthTestData.Signing
	[       OK ] PAuthTestData.Signing (0 ms)
	[ RUN      ] PAuthTestData.Authentication
	[       OK ] PAuthTestData.Authentication (92 ms)
	[ RUN      ] PAuthTestData.Roundtrip
	[       OK ] PAuthTestData.Roundtrip (0 ms)
	[----------] 3 tests from PAuthTestData (92 ms total)

	[----------] Global test environment tear-down
	[==========] 18 tests from 3 test suites ran. (594 ms total)
	[  PASSED  ] 17 tests.
	[  SKIPPED ] 1 test, listed below:
	[  SKIPPED ] PAuthTest.Stripping

.. _docs/totalcompute/tc2/expected-test-results_eas:


EAS with Lisa unit tests
------------------------

::

	The following expressions will be executed:

	EnergyModelWakeMigration:test_dmesg
	EnergyModelWakeMigration:test_slack
	EnergyModelWakeMigration:test_task_placement
	OneSmallTask:test_dmesg
	OneSmallTask:test_slack
	OneSmallTask:test_task_placement
	RampDown:test_dmesg
	RampDown:test_slack
	RampDown:test_task_placement
	RampUp:test_dmesg
	RampUp:test_slack
	RampUp:test_task_placement
	ThreeSmallTasks:test_dmesg
	ThreeSmallTasks:test_slack
	ThreeSmallTasks:test_task_placement
	TwoBigTasks:test_dmesg
	TwoBigTasks:test_slack
	TwoBigTasks:test_task_placement
	TwoBigThreeSmall:test_dmesg
	TwoBigThreeSmall:test_slack
	TwoBigThreeSmall:test_task_placement

	Used trace events:
	  -  sched_switch
	  -  sched_wakeup
	  -  sched_wakeup_new
	  -  task_rename
	  -  userspace@rtapp_loop
	  -  userspace@rtapp_stats

	(...output truncated...)

	[2023-02-20 17:14:06,801][EXEKALL] INFO  Result summary:
	EnergyModelWakeMigration[board=tc2]:test_dmesg          
	UUID=f719a77a37da4c35a287ad4f6f8fef9c PASSED: dmesg output:
	EnergyModelWakeMigration[board=tc2]:test_slack          
	UUID=4e24d5b26b0d4020b3c2cc343082c6ac PASSED: emwm_0-0 delayed 
	activations: 1.3972055888223553 %
	EnergyModelWakeMigration[board=tc2]:test_task_placement 
	UUID=aed8627987f043969c1f76ae4254e2f3 PASSED
	  energy threshold: 7728.922049366228 bogo-joules
	  estimated energy: 7132.289772873224 bogo-joules
	  noisiest task:
	    comm: kworker/5:1
	    duration (abs): 0.0006251400118344463 s
	    duration (rel): 0.007751385789064716 %
	    pid: 69

	OneSmallTask[board=tc2]:test_dmesg                      
	UUID=8feff89476b549c5b6eeaccabc1f9ecf PASSED: dmesg output:
	OneSmallTask[board=tc2]:test_slack                      
	UUID=aad102f781334c6a80c714fc30ceb1bd PASSED: small-0 delayed activations: 
	0.0 %
	OneSmallTask[board=tc2]:test_task_placement             
	UUID=8e1fd6314d644a91be77824e61dd15e6 PASSED
	  energy threshold: 60.32889497785198 bogo-joules
	  estimated energy: 57.45609045509712 bogo-joules
	  noisiest task:
	    comm: init
	    duration (abs): 0.00016386000061174855 s
	    duration (rel): 0.016518059968414968 %
	    pid: 1

	RampDown[board=tc2]:test_dmesg                          
	UUID=496f3d737eec4c8e81e1cdc96aa12982 PASSED: dmesg output:
	RampDown[board=tc2]:test_slack                          
	UUID=b788b6a6f2644e1e9a345466647c485c PASSED: down-0 delayed activations: 
	0.2145922746781116 %
	RampDown[board=tc2]:test_task_placement                 
	UUID=814a50bd7fac46bd80fe8e99f1a94892 PASSED
	  energy threshold: 5075.673823290201 bogo-joules
	  estimated energy: 4476.446074247863 bogo-joules
	  noisiest task:
	    comm: kworker/5:1
	    duration (abs): 0.0005229099842836149 s
	    duration (rel): 0.0070281984591597825 %
	    pid: 69

	RampUp[board=tc2]:test_task_placement                   
	UUID=34733c655ac54a27bb11dad502fe42eb PASSED
	  energy threshold: 4511.993708928746 bogo-joules
	  estimated energy: 3824.991676713266 bogo-joules
	  noisiest task:
	    comm: kworker/5:1
	    duration (abs): 0.0005214800185058266 s
	    duration (rel): 0.007009150123468466 %
	    pid: 69

	ThreeSmallTasks[board=tc2]:test_dmesg                   
	UUID=13dbafe99b5b46d7bf4e0fe111b3ed78 PASSED: dmesg output:
	ThreeSmallTasks[board=tc2]:test_slack                   
	UUID=97567be4278f4f1188f36c3ad3ab9676 PASSED
	  small_0-0 delayed activations: 0.0 %
	  small_1-1 delayed activations: 0.0 %
	  small_2-2 delayed activations: 0.0 %

	ThreeSmallTasks[board=tc2]:test_task_placement          
	UUID=b518bced8a544ddd902f0c254ba9b7da PASSED
	  energy threshold: 206.83944850784022 bogo-joules
	  estimated energy: 172.36620708986686 bogo-joules
	  noisiest task:
	    comm: init
	    duration (abs): 0.00016275000234600157 s
	    duration (rel): 0.016406104698468295 %
	    pid: 1

	TwoBigTasks[board=tc2]:test_dmesg                       
	UUID=52277de98f434f94a72d656a673339af PASSED: dmesg output:
	TwoBigTasks[board=tc2]:test_slack                       
	UUID=eb9e4cf743204830803111c56fc41787 SKIPPED: skipped-reason: The 
	workload will result in overutilized status for all possible task 
	placement, making it unsuitable to test EAS on this platform
	TwoBigTasks[board=tc2]:test_task_placement              
	UUID=76412365246741039321f2f3c0908de5 SKIPPED: skipped-reason: The 
	workload will result in overutilized status for all possible task 
	placement, making it unsuitable to test EAS on this platform
	TwoBigThreeSmall[board=tc2]:test_dmesg                  
	UUID=d7fe6333c65c44b7b801c68d4b9df74e PASSED: dmesg output:
	TwoBigThreeSmall[board=tc2]:test_slack                  
	UUID=b404c2db13064d3e9f596037159b920f SKIPPED: skipped-reason: The 
	workload will result in overutilized status for all possible task 
	placement, making it unsuitable to test EAS on this platform
	TwoBigThreeSmall[board=tc2]:test_task_placement         
	UUID=698d7b4fb84448248caa16db69af185f SKIPPED: skipped-reason: The 
	workload will result in overutilized status for all possible task 
	placement, making it unsuitable to test EAS on this platform

.. _docs/totalcompute/tc2/expected-test-results_cpu_feat:


CPU hardware capabilities
-------------------------

::

	# test_feats_arch.sh
	Testing FEAT_AFP HW CAP
	Pass

	Testing FEAT_ECV HW CAP
	Pass

	Testing FEAT_WFXT HW CAP
	Pass

	#



--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
