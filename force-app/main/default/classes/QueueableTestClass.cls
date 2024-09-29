public with sharing class QueueableTestClass implements Queueable {
    public void execute(QueueableContext context){
            System.debug('QueueableTestClass');
            SecondQueueableClass qs = new SecondQueueableClass();
            AsyncOptions options = new AsyncOptions();
            options.MaximumQueueableStackDepth = 10;
            options.MinimumQueueableDelayInMinutes = 1;
            System.enqueueJob(qs, options);
    }
}