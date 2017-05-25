#include <iostream>
#include <chrono>
#include <thread>
#include "dispatch-c++.hpp"

using namespace dispatch;
using namespace std::literals::chrono_literals;

int TIMES = 5;
auto WORK_TIME = 0.5s;

void work() {
	std::this_thread::sleep_for(WORK_TIME);
}

void serial_work(int times) {
	for (int i = 0; i < TIMES; ++i) 
		{ work(); }
}

void concurrent_work(int times) {
	queue worker_q = queue("edu.carleton.mapreduce", queue::attr::CONCURRENT);
	group worker_group = group();
	for (int i = 0; i < TIMES; ++i)
	{
		worker_group.async(worker_q, [](){
			work();
		});
	}

	worker_group.wait(DISPATCH_TIME_FOREVER);
}

double timer(std::function<void()> emptyLambda) {
	auto start = std::chrono::steady_clock::now();
	emptyLambda();
	auto end = std::chrono::steady_clock::now();
	auto diff = end - start;
	return std::chrono::duration<double> (diff).count();
}

int main(int argc, char* argv[]) {
	printf("Serial Work\n");
	double serialTime = timer([](){
		serial_work(TIMES);
	});

	printf("Concurrent Work\n");
	double concurrentTime = timer([](){
		concurrent_work(TIMES);
	});

	printf("\nserial: %fs"
		"\nconcurrent: %fs"
		"\n\n", serialTime, concurrentTime);
}

