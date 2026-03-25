import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { TransfersService } from './transfers.service';

@Controller('transfers')
@UseGuards(AuthGuard('appwrite-jwt'))
export class TransfersController {
  constructor(private readonly transfersService: TransfersService) {}

  @Post()
  async transfer(
    @Request() req: any,
    @Body()
    body: {
      fromWalletId: string;
      toAddress: string;
      amount: string;
      tokenSymbol: string;
      clientKeyShare: string;
    },
  ) {
    return this.transfersService.executeTransfer(
      req.user.userId,
      body.fromWalletId,
      body.toAddress,
      body.amount,
      body.tokenSymbol,
      body.clientKeyShare,
    );
  }
}
