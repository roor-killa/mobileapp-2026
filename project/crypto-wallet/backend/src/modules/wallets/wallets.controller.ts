import { Controller, Get, Param, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { WalletsService } from './wallets.service';

@Controller('wallets')
@UseGuards(AuthGuard('supabase-jwt'))
export class WalletsController {
  constructor(private readonly walletsService: WalletsService) {}

  @Get()
  async getWallets(@Request() req: { user: { userId: string } }) {
    return this.walletsService.getWallets(req.user.userId);
  }

  @Get(':id/transactions')
  async getTransactions(@Param('id') walletId: string) {
    return this.walletsService.getTransactions(walletId);
  }
}
