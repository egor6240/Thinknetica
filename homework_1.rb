require 'benchmark'
require 'parallel'
require 'async'

# Генерация файлов для примера
files = (0...5).map do |i|
  filename = "file_#{i}.txt"
  File.write(filename, Array.new(100_000) { "Line from #{filename}" }.join("\n"))
  filename
end

# Последовательная обработка файла
def process_files_sequentially(files)
  files.each do |file|
    File.foreach(file) { |line| puts line }
  end
end

# Обработка файла с использованием Threads
def process_files_with_threads(files)
  threads = []

  files.each do |file|
    threads << Thread.new do
      File.foreach(file) { |line| puts line }
    end
  end

  threads.each(&:join)
end

# Обработка файла с использованием Fibers
def process_files_with_fibers(files)
  fibers = files.map do |file|
    Fiber.new do
      File.foreach(file) { |line| puts line }
    end
  end

  fibers.each(&:resume)
end

# Обработка файла с использованием Async
def process_files_with_async(files)
  Async do
    tasks = files.map do |file|
      Async do
        File.foreach(file) { |line| puts line }
      end
    end

    tasks.each(&:wait)
  end
end

# Обработка файла с использованием Ractor
def process_files_with_ractor(files)
  ractors = files.map do |file|
    Ractor.new(file) do |f|
      File.foreach(f) { |line| puts line }
    end
  end

  ractors.each(&:take)
end

# Обработка файла с использованием Parallel
def process_files_with_parallel(files)
  Parallel.each(files) do |file|
    File.foreach(file) { |line| puts line }
  end
end

Benchmark.bm do |x|
  x.report('sequentially') { process_files_sequentially(files) }
  x.report('with threads') { process_files_with_threads(files) }
  x.report('with fibers') { process_files_with_fibers(files) }
  x.report('with async') { process_files_with_async(files) }
  x.report('with ractor') { process_files_with_ractor(files) }
  x.report('with parallel') { process_files_with_parallel(files) }
end
