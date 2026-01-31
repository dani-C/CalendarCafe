import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';

export interface DatabaseConnection {
  isConnected: boolean;
  connect(): Promise<void>;
  disconnect(): Promise<void>;
}

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private connected = false;

  async onModuleInit(): Promise<void> {
    await this.connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.disconnect();
  }

  async connect(): Promise<void> {
    // Mock database connection
    console.log('Mock database connection established');
    this.connected = true;
  }

  async disconnect(): Promise<void> {
    // Mock database disconnection
    console.log('Mock database connection closed');
    this.connected = false;
  }

  isConnected(): boolean {
    return this.connected;
  }
}
